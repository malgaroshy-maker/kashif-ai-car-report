import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';

/// Represents a single fault code extracted from an Ediag PDF scanner report
class EdiagExtractedFault {
  final int itemNumber;
  final String module;
  final String shortModule;
  final String code;
  final String fullCode;
  String description;
  String? status;

  EdiagExtractedFault({
    required this.itemNumber,
    required this.module,
    required this.shortModule,
    required this.code,
    required this.fullCode,
    required this.description,
    this.status,
  });

  @override
  String toString() => '$fullCode: $description ($module)';
}

/// Represents the extracted structured data from an Ediag PDF report
class ExtractedEdiagReport {
  final bool isValid;
  final String rawText;
  final String scannerName;
  final String? serialNumber;
  final String? make;
  final String? model;
  final String? year;
  final String? vin;
  final String? mileage;
  final String? testTime;
  final List<EdiagExtractedFault> faults;
  final List<String> passedSystems;

  const ExtractedEdiagReport({
    required this.isValid,
    required this.rawText,
    this.scannerName = 'فحص إلكتروني شامل',
    this.serialNumber,
    this.make,
    this.model,
    this.year,
    this.vin,
    this.mileage,
    this.testTime,
    this.faults = const [],
    this.passedSystems = const [],
  });

  bool get hasFaults => faults.isNotEmpty;
  bool get hasPassedSystems => passedSystems.isNotEmpty;
}

/// Pure Dart offline extractor for Ediag PDF scanner reports (Format 1: Standard OBD-II, Format 2: BMW/Euro)
class EdiagPdfParser {
  /// Extract structured report data from raw PDF bytes completely offline
  static ExtractedEdiagReport extractFromPdfBytes(Uint8List pdfBytes) {
    final extractedText = extractRawTextFromPdf(pdfBytes);
    return extractFromText(extractedText);
  }

  /// Extracts readable text streams from a PDF binary buffer (with FlateDecode zlib decompression)
  static String extractRawTextFromPdf(Uint8List bytes) {
    final buffer = StringBuffer();

    // Check if it's a PDF
    final isPdf = bytes.length > 4 &&
        bytes[0] == 0x25 && // %
        bytes[1] == 0x50 && // P
        bytes[2] == 0x44 && // D
        bytes[3] == 0x46; // F

    if (!isPdf) {
      // Treat as plain text UTF-8 / Latin-1 if not starting with %PDF
      return utf8.decode(bytes, allowMalformed: true);
    }

    // 1. Scan for and parse any /ToUnicode CMaps in the PDF
    final cMap = _extractAllCmaps(bytes);

    // Locate all 'stream' and 'endstream' blocks
    int cursor = 0;
    final streamKeyword = ascii.encode('stream');
    final endStreamKeyword = ascii.encode('endstream');

    while (cursor < bytes.length) {
      final streamIdx = indexOfSublist(bytes, streamKeyword, cursor);
      if (streamIdx == -1) break;

      // Check preceding dictionary to see if compressed
      final dictStart = streamIdx > 500 ? streamIdx - 500 : 0;
      final dictSlice = bytes.sublist(dictStart, streamIdx);
      final dictString = latin1.decode(dictSlice, allowInvalid: true);
      final isFlate = dictString.contains('/FlateDecode') ||
          dictString.contains('/Fl') ||
          dictString.contains('FlateDecode');

      // Skip newline after 'stream'
      int dataStart = streamIdx + streamKeyword.length;
      if (dataStart < bytes.length && bytes[dataStart] == 0x0D) dataStart++; // \r
      if (dataStart < bytes.length && bytes[dataStart] == 0x0A) dataStart++; // \n

      final endStreamIdx = indexOfSublist(bytes, endStreamKeyword, dataStart);
      if (endStreamIdx == -1) break;

      int dataEnd = endStreamIdx;
      // Trim preceding \r\n before 'endstream'
      if (dataEnd > dataStart && bytes[dataEnd - 1] == 0x0A) dataEnd--;
      if (dataEnd > dataStart && bytes[dataEnd - 1] == 0x0D) dataEnd--;

      final streamBytes = bytes.sublist(dataStart, dataEnd);

      List<int>? decompressed;
      if (isFlate) {
        try {
          decompressed = ZLibDecoder().decodeBytes(streamBytes, verify: false);
        } catch (_) {
          try {
            decompressed = Inflate(streamBytes).getBytes();
          } catch (_) {
            decompressed = streamBytes;
          }
        }
      } else {
        decompressed = streamBytes;
      }

      if (decompressed != null && decompressed.isNotEmpty) {
        if (cMap.isNotEmpty) {
          final parsed = _parseCMapStreamBytes(Uint8List.fromList(decompressed), cMap);
          if (parsed.trim().isNotEmpty) {
            buffer.writeln(parsed);
          }
        } else {
          final streamText = latin1.decode(decompressed, allowInvalid: true);
          final parsedText = _parsePdfStreamOperators(streamText);
          buffer.writeln(parsedText);
        }
      }

      cursor = endStreamIdx + endStreamKeyword.length;
    }

    // Also extract ASCII literal strings from the full PDF as fallback
    final fullAscii = latin1.decode(bytes, allowInvalid: true);
    final textFromOperators = buffer.toString();

    // If stream extraction produced rich text, use it; else merge with ASCII lines
    if (textFromOperators.trim().length > 100) {
      return textFromOperators;
    }

    return '$textFromOperators\n$fullAscii';
  }

  static Map<int, String> _extractAllCmaps(Uint8List bytes) {
    final charMap = <int, String>{};
    final latinPdf = latin1.decode(bytes, allowInvalid: true);
    if (!latinPdf.contains('beginbfrange') &&
        !latinPdf.contains('beginbfchar') &&
        !latinPdf.contains('ToUnicode')) {
      return charMap;
    }

    int cursor = 0;
    final streamKeyword = ascii.encode('stream');
    final endStreamKeyword = ascii.encode('endstream');

    while (cursor < bytes.length) {
      final sIdx = indexOfSublist(bytes, streamKeyword, cursor);
      if (sIdx == -1) break;

      final dictStart = sIdx > 500 ? sIdx - 500 : 0;
      final dictSlice = bytes.sublist(dictStart, sIdx);
      final dictString = latin1.decode(dictSlice, allowInvalid: true);

      int dataStart = sIdx + streamKeyword.length;
      if (dataStart < bytes.length && bytes[dataStart] == 0x0D) dataStart++;
      if (dataStart < bytes.length && bytes[dataStart] == 0x0A) dataStart++;

      final eIdx = indexOfSublist(bytes, endStreamKeyword, dataStart);
      if (eIdx == -1) break;

      int dataEnd = eIdx;
      if (dataEnd > dataStart && bytes[dataEnd - 1] == 0x0A) dataEnd--;
      if (dataEnd > dataStart && bytes[dataEnd - 1] == 0x0D) dataEnd--;

      final streamBytes = bytes.sublist(dataStart, dataEnd);
      final isFlate = dictString.contains('/FlateDecode') ||
          dictString.contains('/Fl') ||
          dictString.contains('FlateDecode');

      List<int>? decompressed;
      if (isFlate) {
        try {
          decompressed = ZLibDecoder().decodeBytes(streamBytes, verify: false);
        } catch (_) {
          try {
            decompressed = Inflate(streamBytes).getBytes();
          } catch (_) {}
        }
      } else {
        decompressed = streamBytes;
      }

      if (decompressed != null && decompressed.isNotEmpty) {
        final streamText = utf8.decode(decompressed, allowMalformed: true);
        if (streamText.contains('beginbfrange') || streamText.contains('beginbfchar')) {
          _parseCMapInto(streamText, charMap);
        }
      }

      cursor = eIdx + endStreamKeyword.length;
    }

    return charMap;
  }

  static void _parseCMapInto(String cmapText, Map<int, String> charMap) {
    // 1. bfchar
    final bfcharBlockRegex = RegExp(r'\d+\s+beginbfchar([\s\S]*?)endbfchar');
    for (final block in bfcharBlockRegex.allMatches(cmapText)) {
      final content = block.group(1) ?? '';
      final entryRegex = RegExp(r'<([0-9a-fA-F]+)>\s*<([0-9a-fA-F]+)>');
      for (final m in entryRegex.allMatches(content)) {
        final src = int.tryParse(m.group(1)!, radix: 16);
        final dstHex = m.group(2)!;
        if (src != null) {
          charMap[src] = _hexToUtf16(dstHex);
        }
      }
    }

    // 2. bfrange
    final bfrangeBlockRegex = RegExp(r'\d+\s+beginbfrange([\s\S]*?)endbfrange');
    for (final block in bfrangeBlockRegex.allMatches(cmapText)) {
      final content = block.group(1) ?? '';

      final rangeSimpleRegex = RegExp(r'<([0-9a-fA-F]+)>\s*<([0-9a-fA-F]+)>\s*<([0-9a-fA-F]+)>');
      for (final m in rangeSimpleRegex.allMatches(content)) {
        final start = int.tryParse(m.group(1)!, radix: 16);
        final end = int.tryParse(m.group(2)!, radix: 16);
        final dstStart = int.tryParse(m.group(3)!, radix: 16);
        if (start != null && end != null && dstStart != null) {
          final count = end - start;
          for (int i = 0; i <= count; i++) {
            charMap[start + i] = String.fromCharCode(dstStart + i);
          }
        }
      }

      final rangeArrayRegex = RegExp(r'<([0-9a-fA-F]+)>\s*<([0-9a-fA-F]+)>\s*\[([\s\S]*?)\]');
      for (final m in rangeArrayRegex.allMatches(content)) {
        final start = int.tryParse(m.group(1)!, radix: 16);
        final end = int.tryParse(m.group(2)!, radix: 16);
        final arrayContent = m.group(3)!;
        if (start != null && end != null) {
          final hexItems = RegExp(r'<([0-9a-fA-F]+)>').allMatches(arrayContent).map((h) => h.group(1)!).toList();
          for (int i = 0; i < hexItems.length && (start + i) <= end; i++) {
            charMap[start + i] = _hexToUtf16(hexItems[i]);
          }
        }
      }
    }
  }

  static String _hexToUtf16(String hex) {
    if (hex.length == 4) {
      final val = int.tryParse(hex, radix: 16);
      return val != null ? String.fromCharCode(val) : '';
    }
    final sb = StringBuffer();
    for (int i = 0; i < hex.length; i += 4) {
      if (i + 4 <= hex.length) {
        final val = int.tryParse(hex.substring(i, i + 4), radix: 16);
        if (val != null) sb.writeCharCode(val);
      }
    }
    return sb.toString();
  }

  static List<int> _unescapePdfBytes(List<int> raw) {
    final out = <int>[];
    int i = 0;
    while (i < raw.length) {
      if (raw[i] == 92 && i + 1 < raw.length) { // '\'
        final next = raw[i + 1];
        if (next == 110) { out.add(10); i += 2; continue; } // \n
        if (next == 114) { out.add(13); i += 2; continue; } // \r
        if (next == 116) { out.add(9); i += 2; continue; }  // \t
        if (next == 98) { out.add(8); i += 2; continue; }   // \b
        if (next == 102) { out.add(12); i += 2; continue; } // \f (Form Feed)
        if (next == 40 || next == 41 || next == 92) { out.add(next); i += 2; continue; } // \( \) \\
        if (next >= 48 && next <= 55) {
          int octal = next - 48;
          int len = 1;
          if (i + 2 < raw.length && raw[i + 2] >= 48 && raw[i + 2] <= 55) {
            octal = (octal << 3) + (raw[i + 2] - 48);
            len = 2;
            if (i + 3 < raw.length && raw[i + 3] >= 48 && raw[i + 3] <= 55) {
              octal = (octal << 3) + (raw[i + 3] - 48);
              len = 3;
            }
          }
          out.add(octal);
          i += 1 + len;
          continue;
        }
      }
      out.add(raw[i]);
      i++;
    }
    return out;
  }

  static String _parseCMapStreamBytes(Uint8List rawBytes, Map<int, String> cMap) {
    final out = StringBuffer();
    int pos = 0;
    while (pos < rawBytes.length) {
      final b = rawBytes[pos];
      if (b == 40) { // '('
        int endPos = pos + 1;
        int depth = 1;
        while (endPos < rawBytes.length && depth > 0) {
          if (rawBytes[endPos] == 92) {
            endPos += 2;
            continue;
          }
          if (rawBytes[endPos] == 40) depth++;
          else if (rawBytes[endPos] == 41) depth--;
          endPos++;
        }
        if (depth == 0) {
          final strBytes = _unescapePdfBytes(rawBytes.sublist(pos + 1, endPos - 1));
          for (int k = 0; k + 1 < strBytes.length; k += 2) {
            final code = (strBytes[k] << 8) | strBytes[k + 1];
            out.write(cMap[code] ?? String.fromCharCode(code & 0xFF));
          }
          pos = endPos;
          continue;
        }
      } else if (b == 10 || b == 13) {
        out.writeln();
      }
      pos++;
    }
    return out.toString();
  }

  /// Extracts text strings enclosed in PDF operators like (...) Tj and [...] TJ
  static String _parsePdfStreamOperators(String content) {
    final out = StringBuffer();
    final len = content.length;
    int i = 0;

    while (i < len) {
      final ch = content[i];

      // Single string (string) Tj or ' or "
      if (ch == '(') {
        final strEnd = _findMatchingParen(content, i);
        if (strEnd != -1) {
          final rawStr = content.substring(i + 1, strEnd);
          final text = _unescapePdfString(rawStr);
          out.write(text);

          // Check if followed by newline or text positioning
          i = strEnd + 1;
          continue;
        }
      }
      // Array [(string) 20 (string)] TJ
      else if (ch == '[') {
        final bracketEnd = content.indexOf(']', i);
        if (bracketEnd != -1) {
          final arrayContent = content.substring(i + 1, bracketEnd);
          final arrayText = _extractStringsFromArray(arrayContent);
          out.write(arrayText);
          i = bracketEnd + 1;
          continue;
        }
      }
      // Line breaks in PDF text layout (ET, T*, TD, Td)
      else if (ch == 'E' && i + 1 < len && content[i + 1] == 'T') {
        out.writeln();
        i += 2;
        continue;
      } else if (ch == 'T' && i + 1 < len && (content[i + 1] == '*' || content[i + 1] == 'D' || content[i + 1] == 'd')) {
        out.writeln();
        i += 2;
        continue;
      } else if (ch == '\n' || ch == '\r') {
        out.writeln();
      }

      i++;
    }

    return out.toString();
  }

  static String _extractStringsFromArray(String arrayContent) {
    final sb = StringBuffer();
    int i = 0;
    while (i < arrayContent.length) {
      if (arrayContent[i] == '(') {
        final end = _findMatchingParen(arrayContent, i);
        if (end != -1) {
          final raw = arrayContent.substring(i + 1, end);
          sb.write(_unescapePdfString(raw));
          i = end + 1;
          continue;
        }
      }
      i++;
    }
    return sb.toString();
  }

  static int _findMatchingParen(String s, int start) {
    int depth = 0;
    for (int i = start; i < s.length; i++) {
      if (s[i] == '\\') {
        i++; // skip escaped char
        continue;
      }
      if (s[i] == '(') depth++;
      if (s[i] == ')') {
        depth--;
        if (depth == 0) return i;
      }
    }
    return -1;
  }

  static String _unescapePdfString(String raw) {
    return raw
        .replaceAll(r'\(', '(')
        .replaceAll(r'\)', ')')
        .replaceAll(r'\\', r'\')
        .replaceAll(r'\r', '\r')
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\t', '\t');
  }

  static int indexOfSublist(Uint8List list, List<int> pattern, int start) {
    if (pattern.isEmpty || start >= list.length) return -1;
    final max = list.length - pattern.length;
    for (int i = start; i <= max; i++) {
      bool match = true;
      for (int j = 0; j < pattern.length; j++) {
        if (list[i + j] != pattern[j]) {
          match = false;
          break;
        }
      }
      if (match) return i;
    }
    return -1;
  }

  /// Parses text representations of Ediag reports (both Toyota OBD-II & BMW Multi-module formats)
  static ExtractedEdiagReport extractFromText(String rawText) {
    // 1. Check if this is an Ediag report
    final isEdiag = rawText.contains('All System Diagnostic Report') ||
        rawText.contains('The Report is created by Ediag') ||
        rawText.contains('Vehicle Information') ||
        rawText.contains('Inspection Result') ||
        rawText.contains('problems exist') ||
        rawText.contains('The following systems are OK:');

    // 2. Extract Vehicle Metadata
    final snMatch = RegExp(r'SN[:\s]*([A-Za-z0-9]+)', caseSensitive: false).firstMatch(rawText);
    final serialNumber = snMatch?.group(1)?.trim();

    final makeMatch = RegExp(r'Make[:\s]*([^\r\n]+)', caseSensitive: false).firstMatch(rawText);
    final rawMake = makeMatch?.group(1)?.trim();

    final modelMatch = RegExp(r'Model[:\s]*([^\r\n]+)', caseSensitive: false).firstMatch(rawText);
    final rawModel = modelMatch?.group(1)?.trim();

    final yearMatch = RegExp(r'Year[:\s]*([^\r\n]+)', caseSensitive: false).firstMatch(rawText);
    final rawYear = yearMatch?.group(1)?.trim();

    final vinMatch = RegExp(r'VIN[:\s]*([A-HJ-NPR-Z0-9]{17})', caseSensitive: false).firstMatch(rawText);
    final rawVin = vinMatch?.group(1)?.trim()?.toUpperCase();

    final mileageMatch = RegExp(r'Mileage[:\s]*([^\r\n]+)', caseSensitive: false).firstMatch(rawText);
    final rawMileage = mileageMatch?.group(1)?.trim();

    final testTimeMatch = RegExp(r'Test Time[:\s]*([^\r\n]+)', caseSensitive: false).firstMatch(rawText);
    final rawTestTime = testTimeMatch?.group(1)?.trim();

    // 3. Extract Fault Codes and Passed Systems line-by-line
    final lines = rawText
        .split(RegExp(r'[\r\n]+'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    String currentModuleName = 'ECM';
    String currentShortModule = 'ECM';
    bool inOkSection = false;

    final List<EdiagExtractedFault> faults = [];
    final List<String> passedSystems = [];

    // Module header regex: e.g. "ECM-Engine Control Module - DME/DDE 2 problems exist" or "SRS-Supplemental Inflatable Restraint System 8 problems exist"
    final moduleHeaderRegex = RegExp(r'^(.+?)\s+(\d+)\s+problems?\s+exist', caseSensitive: false);

    // Standard OBD-II fault line: e.g. "1.B1811 Open in Driver's Squib..." or "1.P0102 ..."
    final standardFaultRegex = RegExp(r'^(\d+)\.([BPCU][0-9A-Fa-f]{4})\s+(.+)$');

    // Proprietary Hex fault line: e.g. "1.D6 Road - Speed Signal" or "2.02 Ignition, Cylinder 4" or "1.29 Wheel Speed"
    final hexFaultRegex = RegExp(r'^(\d+)\.([A-Fa-f0-9]{2,4})\s+(.+)$');

    // Passed system line: e.g. "1.EWS-Elec. Immobilize System"
    final passedSystemRegex = RegExp(r'^(\d+)\.\s*(.+)$');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Detect start of OK systems
      if (line.contains('The following systems are OK:') ||
          line.contains('systems are OK:')) {
        inOkSection = true;
        continue;
      }

      // Check if entering a new module header
      final modMatch = moduleHeaderRegex.firstMatch(line);
      if (modMatch != null) {
        inOkSection = false;
        currentModuleName = modMatch.group(1)!.trim();
        currentShortModule = _resolveShortModuleName(currentModuleName);
        continue;
      }

      if (inOkSection) {
        final okMatch = passedSystemRegex.firstMatch(line);
        if (okMatch != null) {
          final sysName = okMatch.group(2)!.trim();
          if (!passedSystems.contains(sysName)) {
            passedSystems.add(sysName);
          }
          continue;
        }
      }

      // Check if line is a status line for the preceding fault
      // e.g. "Present", "Active", "Stored", "Pending", "History", "Current", "Fault currently present"
      final isStatusLine = RegExp(
        r'^(Present|Active|Stored|Pending|History|Current|Permanent|Intermittent|Fault\s+.*)$',
        caseSensitive: false,
      ).hasMatch(line);

      if (isStatusLine && faults.isNotEmpty && !inOkSection) {
        faults.last.status = line;
        continue;
      }

      // Check for Standard OBD-II fault: e.g. "1.B1811 ..." or "1.C1259 ..."
      final stdMatch = standardFaultRegex.firstMatch(line);
      if (stdMatch != null) {
        final itemNum = int.tryParse(stdMatch.group(1)!) ?? (faults.length + 1);
        final code = stdMatch.group(2)!.toUpperCase();
        var rawDesc = stdMatch.group(3)!.trim();
        String? inlineStatus;

        // Strip trailing status if attached to same line (e.g. "1.C1259 Sensor-Electrical Present")
        final statusSuffixMatch = RegExp(
          r'\s+(Present|Active|Stored|Pending|History|Current|Permanent)$',
          caseSensitive: false,
        ).firstMatch(rawDesc);
        if (statusSuffixMatch != null) {
          inlineStatus = statusSuffixMatch.group(1);
          rawDesc = rawDesc.substring(0, statusSuffixMatch.start).trim();
        }

        final fault = EdiagExtractedFault(
          itemNumber: itemNum,
          module: currentModuleName,
          shortModule: currentShortModule,
          code: code,
          fullCode: code,
          description: rawDesc,
          status: inlineStatus,
        );
        faults.add(fault);
        continue;
      }

      // Check for European / BMW Hex fault
      final hexMatch = hexFaultRegex.firstMatch(line);
      if (hexMatch != null) {
        final itemNum = int.tryParse(hexMatch.group(1)!) ?? (faults.length + 1);
        final code = hexMatch.group(2)!.toUpperCase();
        var rawDesc = hexMatch.group(3)!.trim();
        String? inlineStatus;

        final statusSuffixMatch = RegExp(
          r'\s+(Present|Active|Stored|Pending|History|Current|Permanent)$',
          caseSensitive: false,
        ).firstMatch(rawDesc);
        if (statusSuffixMatch != null) {
          inlineStatus = statusSuffixMatch.group(1);
          rawDesc = rawDesc.substring(0, statusSuffixMatch.start).trim();
        }

        final fullCode = '$currentShortModule $code';

        final fault = EdiagExtractedFault(
          itemNumber: itemNum,
          module: currentModuleName,
          shortModule: currentShortModule,
          code: code,
          fullCode: fullCode,
          description: rawDesc,
          status: inlineStatus,
        );
        faults.add(fault);
        continue;
      }

      // Wrapped description line continuation for previous fault (e.g. "Circuit" on next line)
      if (faults.isNotEmpty &&
          !inOkSection &&
          !line.startsWith(RegExp(r'\d+\.')) &&
          !line.contains('Diagnostic Report') &&
          !line.contains('Vehicle Information') &&
          !line.contains('Inspection Result') &&
          !line.contains(':') &&
          line.length < 120) {
        faults.last.description += ' $line';
      }
    }

    final isValidReport = isEdiag || faults.isNotEmpty || rawVin != null || rawMake != null;

    return ExtractedEdiagReport(
      isValid: isValidReport,
      rawText: rawText,
      scannerName: 'فحص كمبيوتر شامل',
      serialNumber: serialNumber,
      make: rawMake,
      model: rawModel,
      year: rawYear,
      vin: rawVin,
      mileage: rawMileage,
      testTime: rawTestTime,
      faults: faults,
      passedSystems: passedSystems,
    );
  }

  static String _resolveShortModuleName(String fullModule) {
    final upper = fullModule.toUpperCase();
    if (upper.contains('ECM') || upper.contains('DME') || upper.contains('ENGINE')) {
      return 'ECM';
    }
    if (upper.contains('TCM') || upper.contains('EGS') || upper.contains('TRANSMISSION')) {
      return 'TCM';
    }
    if (upper.contains('ABS') || upper.contains('DSC') || upper.contains('BRAK')) {
      return 'ABS';
    }
    if (upper.contains('EPS') || upper.contains('STEERING') || upper.contains('POWER STEERING')) {
      return 'EPS';
    }
    if (upper.contains('IC') || upper.contains('INSTR') || upper.contains('CLUSTER')) {
      return 'IC';
    }
    if (upper.contains('SRS') || upper.contains('AIRBAG') || upper.contains('RESTRAINT')) {
      return 'SRS';
    }
    if (upper.contains('LSZ') || upper.contains('LCM') || upper.contains('LIGHT')) {
      return 'LSZ';
    }
    if (upper.contains('BCM') || upper.contains('BODY')) {
      return 'BCM';
    }
    if (upper.contains('EWS') || upper.contains('IMMOBILIZ') || upper.contains('IMM')) {
      return 'IMM';
    }

    final parts = fullModule.split(RegExp(r'[-/\s]'));
    if (parts.isNotEmpty && parts.first.isNotEmpty) {
      return parts.first.toUpperCase();
    }
    return 'OBD';
  }
}
