/**
 * High-Definition Vector Automotive Component Visuals
 * Self-contained, offline-ready, responsive SVG illustrations
 * Designed for Kashif AI High-Tech Automotive Design System.
 */

export interface PartVisualMetadata {
  type: string;
  categoryArabic: string;
  pinsOrSpecs: string;
  colorAccent: string;
}

export function getPartVisualType(partName: string = "", oem: string = ""): string {
  const p = (partName + " " + oem).toLowerCase();
  if (p.includes("لمدا") || p.includes("lambda") || p.includes("oxygen") || p.includes("o2") || p.includes("عادم") || p.includes("شكمان")) {
    return "OXYGEN_SENSOR";
  }
  if (p.includes("بوبين") || p.includes("كويل") || p.includes("coil") || p.includes("ignition")) {
    return "IGNITION_COIL";
  }
  if (p.includes("شمع") || p.includes("بوجي") || p.includes("spark") || p.includes("plug")) {
    return "SPARK_PLUG";
  }
  if (p.includes("تيرستات") || p.includes("thermostat") || p.includes("حرارة") || p.includes("كوع")) {
    return "THERMOSTAT";
  }
  if (p.includes("طرمبة") || p.includes("بومبة بنزين") || p.includes("fuel pump") || p.includes("بانزين") || p.includes("ضغط الوقود")) {
    return "FUEL_PUMP";
  }
  if (p.includes("ماف") || p.includes("maf") || p.includes("air flow") || p.includes("حساس هواء") || p.includes("فيلترو")) {
    return "MAF_SENSOR";
  }
  if (p.includes("كتالايزر") || p.includes("كربون") || p.includes("catalytic") || p.includes("بيئة") || p.includes("دبة")) {
    return "CATALYTIC_CONVERTER";
  }
  if (p.includes("ديسك") || p.includes("فرامل") || p.includes("brake") || p.includes("فحمات") || p.includes("قماشات")) {
    return "BRAKE_DISC";
  }
  if (p.includes("مكيف") || p.includes("compressor") || p.includes("كومبروسر")) {
    return "AC_COMPRESSOR";
  }
  if (p.includes("abs") || p.includes("سرعة عجل") || p.includes("speed sensor")) {
    return "ABS_SENSOR";
  }
  if (p.includes("بومبة مية") || p.includes("water pump") || p.includes("مضخة ماء")) {
    return "WATER_PUMP";
  }
  return "GENERIC_PART";
}

export function getPartSvg(partName: string = "", oem: string = ""): string {
  const type = getPartVisualType(partName, oem);

  switch (type) {
    case "OXYGEN_SENSOR":
      return `<svg viewBox="0 0 240 180" width="100%" height="100%" xmlns="http://www.w3.org/2000/svg" class="part-svg">
        <defs>
          <linearGradient id="o2_metal" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stop-color="#94a3b8" />
            <stop offset="50%" stop-color="#475569" />
            <stop offset="100%" stop-color="#1e293b" />
          </linearGradient>
          <linearGradient id="o2_glow" x1="0%" y1="0%" x2="100%" y2="0%">
            <stop offset="0%" stop-color="#00F0FF" stop-opacity="0.8"/>
            <stop offset="100%" stop-color="#0284c7" stop-opacity="0.3"/>
          </linearGradient>
          <linearGradient id="o2_tip" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stop-color="#f59e0b"/>
            <stop offset="100%" stop-color="#b45309"/>
          </linearGradient>
        </defs>
        <!-- Background Grid Gridlines -->
        <rect width="240" height="180" rx="16" fill="#070D1E" stroke="#1e293b" stroke-width="1.5"/>
        <path d="M 20 90 H 220 M 120 20 V 160" stroke="#00F0FF" stroke-opacity="0.1" stroke-dasharray="3 3"/>
        <circle cx="120" cy="90" r="65" stroke="#00F0FF" stroke-opacity="0.08" fill="none"/>
        
        <!-- Wiring Harness Wire -->
        <path d="M 175 45 C 195 40 215 55 210 80 C 205 105 220 120 225 140" fill="none" stroke="#0f172a" stroke-width="8" stroke-linecap="round"/>
        <path d="M 175 45 C 195 40 215 55 210 80 C 205 105 220 120 225 140" fill="none" stroke="#00F0FF" stroke-width="3" stroke-linecap="round" stroke-dasharray="8 4"/>
        
        <!-- Connector Plug -->
        <rect x="205" y="130" width="22" height="35" rx="5" fill="#1e293b" stroke="#00F0FF" stroke-width="1.5"/>
        <rect x="210" y="160" width="12" height="8" rx="2" fill="#0284c7"/>
        <circle cx="216" cy="142" r="2.5" fill="#10B981"/>
        <circle cx="216" cy="150" r="2.5" fill="#00F0FF"/>

        <!-- Sensor Hex Nut Body -->
        <polygon points="120,40 155,58 155,95 120,115 85,95 85,58" fill="url(#o2_metal)" stroke="#94a3b8" stroke-width="2"/>
        <circle cx="120" cy="77" r="16" fill="#0b132b" stroke="#00F0FF" stroke-width="1.5"/>
        <circle cx="120" cy="77" r="7" fill="#00F0FF"/>

        <!-- Threaded Section -->
        <rect x="95" y="112" width="50" height="22" rx="3" fill="#334155" stroke="#64748b" stroke-width="1.5"/>
        <line x1="95" y1="117" x2="145" y2="117" stroke="#94a3b8" stroke-width="1.5"/>
        <line x1="95" y1="123" x2="145" y2="123" stroke="#94a3b8" stroke-width="1.5"/>
        <line x1="95" y1="129" x2="145" y2="129" stroke="#94a3b8" stroke-width="1.5"/>

        <!-- Sensor Probe Tip (Heated Zirconia Tube) -->
        <path d="M 103 134 L 103 162 C 103 169 137 169 137 162 L 137 134 Z" fill="url(#o2_tip)" stroke="#d97706" stroke-width="1.5"/>
        <!-- Sniffer Holes -->
        <circle cx="112" cy="144" r="2.5" fill="#451a03"/>
        <circle cx="128" cy="144" r="2.5" fill="#451a03"/>
        <circle cx="120" cy="154" r="2.5" fill="#451a03"/>

        <!-- Upper Sleeve -->
        <rect x="108" y="24" width="24" height="22" rx="4" fill="url(#o2_metal)" stroke="#cbd5e1" stroke-width="1"/>

        <!-- Technical Telemetry Badge -->
        <rect x="12" y="12" width="76" height="20" rx="6" fill="#00F0FF" fill-opacity="0.15" stroke="#00F0FF" stroke-width="1"/>
        <text x="50" y="26" fill="#00F0FF" font-family="monospace" font-size="10" font-weight="bold" text-anchor="middle">O2 SENSOR</text>
        <text x="228" y="26" fill="#10B981" font-family="monospace" font-size="9" font-weight="bold" text-anchor="end">4-WIRE HEATED</text>
      </svg>`;

    case "IGNITION_COIL":
      return `<svg viewBox="0 0 240 180" width="100%" height="100%" xmlns="http://www.w3.org/2000/svg" class="part-svg">
        <defs>
          <linearGradient id="coil_body" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stop-color="#1e293b" />
            <stop offset="50%" stop-color="#0f172a" />
            <stop offset="100%" stop-color="#020617" />
          </linearGradient>
          <linearGradient id="coil_boot" x1="0%" y1="0%" x2="100%" y2="0%">
            <stop offset="0%" stop-color="#334155" />
            <stop offset="100%" stop-color="#1e293b" />
          </linearGradient>
        </defs>
        <rect width="240" height="180" rx="16" fill="#070D1E" stroke="#1e293b" stroke-width="1.5"/>
        <path d="M 20 90 H 220 M 120 20 V 160" stroke="#FFB800" stroke-opacity="0.1" stroke-dasharray="3 3"/>
        
        <!-- Coil Head Module -->
        <rect x="65" y="32" width="110" height="42" rx="8" fill="url(#coil_body)" stroke="#475569" stroke-width="2"/>
        <rect x="75" y="38" width="90" height="12" rx="4" fill="#0f172a" stroke="#FFB800" stroke-width="1"/>
        <!-- 3-Pin Electrical Terminal -->
        <rect x="155" y="44" width="30" height="18" rx="4" fill="#334155" stroke="#94a3b8" stroke-width="1.5"/>
        <line x1="165" y1="48" x2="165" y2="58" stroke="#FFB800" stroke-width="2"/>
        <line x1="172" y1="48" x2="172" y2="58" stroke="#FFB800" stroke-width="2"/>
        <line x1="179" y1="48" x2="179" y2="58" stroke="#FFB800" stroke-width="2"/>

        <!-- Mounting Bolt Ear -->
        <path d="M 65 52 C 45 52 45 68 65 68 Z" fill="#334155" stroke="#64748b" stroke-width="1.5"/>
        <circle cx="56" cy="60" r="4.5" fill="#070D1E" stroke="#cbd5e1" stroke-width="1.5"/>

        <!-- Long Insulated Shaft -->
        <rect x="108" y="74" width="24" height="60" fill="url(#coil_boot)" stroke="#475569" stroke-width="1.5"/>
        <!-- Ribbed Rubber Boot -->
        <path d="M 102 134 L 138 134 L 134 165 C 134 168 106 168 106 165 Z" fill="#0f172a" stroke="#FFB800" stroke-width="1.5"/>
        <line x1="104" y1="142" x2="136" y2="142" stroke="#64748b" stroke-width="1.5"/>
        <line x1="105" y1="150" x2="135" y2="150" stroke="#64748b" stroke-width="1.5"/>
        
        <!-- High Voltage Spark Core Indicator -->
        <circle cx="120" cy="162" r="3" fill="#00F0FF"/>

        <!-- Badge -->
        <rect x="12" y="12" width="90" height="20" rx="6" fill="#FFB800" fill-opacity="0.15" stroke="#FFB800" stroke-width="1"/>
        <text x="57" y="26" fill="#FFB800" font-family="monospace" font-size="10" font-weight="bold" text-anchor="middle">IGNITION COIL</text>
        <text x="228" y="26" fill="#00F0FF" font-family="monospace" font-size="9" font-weight="bold" text-anchor="end">HIGH VOLTAGE</text>
      </svg>`;

    case "SPARK_PLUG":
      return `<svg viewBox="0 0 240 180" width="100%" height="100%" xmlns="http://www.w3.org/2000/svg" class="part-svg">
        <defs>
          <linearGradient id="ceramic" x1="0%" y1="0%" x2="100%" y2="0%">
            <stop offset="0%" stop-color="#ffffff"/>
            <stop offset="50%" stop-color="#e2e8f0"/>
            <stop offset="100%" stop-color="#94a3b8"/>
          </linearGradient>
          <linearGradient id="plug_metal" x1="0%" y1="0%" x2="100%" y2="0%">
            <stop offset="0%" stop-color="#cbd5e1"/>
            <stop offset="50%" stop-color="#64748b"/>
            <stop offset="100%" stop-color="#334155"/>
          </linearGradient>
        </defs>
        <rect width="240" height="180" rx="16" fill="#070D1E" stroke="#1e293b" stroke-width="1.5"/>
        
        <!-- Top Terminal Stud -->
        <rect x="115" y="18" width="10" height="14" rx="2" fill="#94a3b8" stroke="#cbd5e1" stroke-width="1"/>
        
        <!-- White Ceramic Insulator with Corrugations -->
        <path d="M 112 32 L 128 32 L 131 82 L 109 82 Z" fill="url(#ceramic)" stroke="#cbd5e1" stroke-width="1.5"/>
        <line x1="110" y1="42" x2="130" y2="42" stroke="#00F0FF" stroke-width="1.5" stroke-opacity="0.8"/>
        <line x1="110" y1="52" x2="130" y2="52" stroke="#00F0FF" stroke-width="1.5" stroke-opacity="0.8"/>
        <line x1="111" y1="62" x2="129" y2="62" stroke="#00F0FF" stroke-width="1.5" stroke-opacity="0.8"/>

        <!-- Hex Shell Nut -->
        <polygon points="120,80 148,92 148,110 120,122 92,110 92,92" fill="url(#plug_metal)" stroke="#94a3b8" stroke-width="1.5"/>

        <!-- Threaded Body -->
        <rect x="105" y="120" width="30" height="32" rx="2" fill="#475569" stroke="#94a3b8" stroke-width="1.5"/>
        <line x1="105" y1="126" x2="135" y2="126" stroke="#cbd5e1" stroke-width="1.5"/>
        <line x1="105" y1="132" x2="135" y2="132" stroke="#cbd5e1" stroke-width="1.5"/>
        <line x1="105" y1="138" x2="135" y2="138" stroke="#cbd5e1" stroke-width="1.5"/>
        <line x1="105" y1="144" x2="135" y2="144" stroke="#cbd5e1" stroke-width="1.5"/>

        <!-- Gasket Washer -->
        <rect x="98" y="118" width="44" height="4" rx="2" fill="#d97706"/>

        <!-- Center Electrode & Ground J-Gap -->
        <rect x="117" y="152" width="6" height="12" fill="#00F0FF"/>
        <path d="M 129 152 L 129 168 L 115 168" fill="none" stroke="#94a3b8" stroke-width="3" stroke-linecap="round"/>

        <!-- Spark Flash Micro-Glow -->
        <circle cx="120" cy="165" r="4" fill="#00F0FF" filter="drop-shadow(0 0 6px #00F0FF)"/>

        <!-- Badge -->
        <rect x="12" y="12" width="80" height="20" rx="6" fill="#10B981" fill-opacity="0.15" stroke="#10B981" stroke-width="1"/>
        <text x="52" y="26" fill="#10B981" font-family="monospace" font-size="10" font-weight="bold" text-anchor="middle">SPARK PLUG</text>
        <text x="228" y="26" fill="#FFB800" font-family="monospace" font-size="9" font-weight="bold" text-anchor="end">IRIDIUM / PLATINUM</text>
      </svg>`;

    case "THERMOSTAT":
      return `<svg viewBox="0 0 240 180" width="100%" height="100%" xmlns="http://www.w3.org/2000/svg" class="part-svg">
        <defs>
          <linearGradient id="brass" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stop-color="#fde047"/>
            <stop offset="50%" stop-color="#ca8a04"/>
            <stop offset="100%" stop-color="#854d0e"/>
          </linearGradient>
          <linearGradient id="housing" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stop-color="#64748b"/>
            <stop offset="100%" stop-color="#1e293b"/>
          </linearGradient>
        </defs>
        <rect width="240" height="180" rx="16" fill="#070D1E" stroke="#1e293b" stroke-width="1.5"/>
        
        <!-- Outer Flange Disc -->
        <ellipse cx="120" cy="65" rx="72" ry="24" fill="url(#housing)" stroke="#94a3b8" stroke-width="2"/>
        <ellipse cx="120" cy="65" rx="50" ry="16" fill="#070D1E" stroke="#00F0FF" stroke-width="1.5"/>
        
        <!-- Rubber Seal Ring -->
        <ellipse cx="120" cy="65" rx="68" ry="22" fill="none" stroke="#0284c7" stroke-width="3"/>

        <!-- Support Bridge Arms -->
        <path d="M 68 65 L 85 135 L 155 135 L 172 65" fill="none" stroke="#94a3b8" stroke-width="4" stroke-linejoin="round"/>

        <!-- Heavy Spring Coils -->
        <path d="M 98 80 C 142 80 142 90 98 90 C 142 90 142 100 98 100 C 142 100 142 110 98 110 C 142 110 142 120 98 120" 
              fill="none" stroke="#cbd5e1" stroke-width="4.5" stroke-linecap="round"/>

        <!-- Central Wax Pellet Cylinder (Brass) -->
        <rect x="110" y="70" width="20" height="55" rx="5" fill="url(#brass)" stroke="#713f12" stroke-width="1.5"/>
        <!-- Bleeder Jiggle Pin Valve -->
        <circle cx="145" cy="58" r="3.5" fill="#f59e0b" stroke="#78350f" stroke-width="1"/>

        <!-- Temperature Rating Badge -->
        <rect x="12" y="12" width="88" height="20" rx="6" fill="#00F0FF" fill-opacity="0.15" stroke="#00F0FF" stroke-width="1"/>
        <text x="56" y="26" fill="#00F0FF" font-family="monospace" font-size="10" font-weight="bold" text-anchor="middle">THERMOSTAT</text>
        <text x="228" y="26" fill="#FF3B30" font-family="monospace" font-size="9" font-weight="bold" text-anchor="end">88°C - 105°C</text>
      </svg>`;

    case "FUEL_PUMP":
      return `<svg viewBox="0 0 240 180" width="100%" height="100%" xmlns="http://www.w3.org/2000/svg" class="part-svg">
        <defs>
          <linearGradient id="pump_cylinder" x1="0%" y1="0%" x2="100%" y2="0%">
            <stop offset="0%" stop-color="#cbd5e1"/>
            <stop offset="50%" stop-color="#64748b"/>
            <stop offset="100%" stop-color="#1e293b"/>
          </linearGradient>
        </defs>
        <rect width="240" height="180" rx="16" fill="#070D1E" stroke="#1e293b" stroke-width="1.5"/>
        
        <!-- Main Pump Cylindrical Canister -->
        <rect x="85" y="45" width="70" height="85" rx="10" fill="url(#pump_cylinder)" stroke="#94a3b8" stroke-width="2"/>
        
        <!-- In-tank Strainer Sock (Mesh Filter) at Bottom -->
        <path d="M 70 148 C 65 160 175 160 170 148 L 128 130 L 112 130 Z" fill="#334155" stroke="#00F0FF" stroke-width="1.5" stroke-dasharray="4 2"/>
        <line x1="80" y1="152" x2="160" y2="152" stroke="#00F0FF" stroke-width="1" stroke-opacity="0.5"/>

        <!-- Top Fuel Outlet Spigot & Electrical Connector -->
        <rect x="100" y="22" width="12" height="24" rx="3" fill="#38bdf8" stroke="#0284c7" stroke-width="1.5"/>
        <rect x="124" y="26" width="20" height="20" rx="3" fill="#1e293b" stroke="#FFB800" stroke-width="1.5"/>
        <circle cx="130" cy="36" r="2" fill="#FFB800"/>
        <circle cx="138" cy="36" r="2" fill="#FFB800"/>

        <!-- Fuel Pressure Bar Gauge Indicator -->
        <rect x="95" y="65" width="50" height="8" rx="4" fill="#070D1E"/>
        <rect x="97" y="67" width="36" height="4" rx="2" fill="#10B981"/>
        <text x="120" y="95" fill="#f1f5f9" font-family="monospace" font-size="10" font-weight="bold" text-anchor="middle">HIGH PRESSURE</text>
        <text x="120" y="112" fill="#38bdf8" font-family="monospace" font-size="9" text-anchor="middle">4.2 BAR / 60 PSI</text>

        <!-- Badge -->
        <rect x="12" y="12" width="78" height="20" rx="6" fill="#FFB800" fill-opacity="0.15" stroke="#FFB800" stroke-width="1"/>
        <text x="51" y="26" fill="#FFB800" font-family="monospace" font-size="10" font-weight="bold" text-anchor="middle">FUEL PUMP</text>
        <text x="228" y="26" fill="#10B981" font-family="monospace" font-size="9" font-weight="bold" text-anchor="end">ELECTRIC IN-TANK</text>
      </svg>`;

    case "CATALYTIC_CONVERTER":
      return `<svg viewBox="0 0 240 180" width="100%" height="100%" xmlns="http://www.w3.org/2000/svg" class="part-svg">
        <defs>
          <linearGradient id="cat_body" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stop-color="#94a3b8"/>
            <stop offset="50%" stop-color="#475569"/>
            <stop offset="100%" stop-color="#1e293b"/>
          </linearGradient>
        </defs>
        <rect width="240" height="180" rx="16" fill="#070D1E" stroke="#1e293b" stroke-width="1.5"/>
        
        <!-- Left Exhaust Inlet Pipe -->
        <path d="M 25 78 L 65 78 L 78 55 L 162 55 L 175 78 L 215 78 L 215 102 L 175 102 L 162 125 L 78 125 L 65 102 L 25 102 Z" 
              fill="url(#cat_body)" stroke="#cbd5e1" stroke-width="2"/>
        
        <!-- Flange Mounts -->
        <rect x="18" y="70" width="8" height="40" rx="2" fill="#334155" stroke="#94a3b8" stroke-width="1.5"/>
        <rect x="214" y="70" width="8" height="40" rx="2" fill="#334155" stroke="#94a3b8" stroke-width="1.5"/>

        <!-- Honeycomb Ceramic Monolith Cutout Window -->
        <rect x="88" y="65" width="64" height="50" rx="6" fill="#0b132b" stroke="#FFB800" stroke-width="1.5"/>
        <!-- Honeycomb Matrix Lines -->
        <line x1="96" y1="65" x2="96" y2="115" stroke="#FFB800" stroke-opacity="0.4" stroke-dasharray="3 2"/>
        <line x1="108" y1="65" x2="108" y2="115" stroke="#FFB800" stroke-opacity="0.4" stroke-dasharray="3 2"/>
        <line x1="120" y1="65" x2="120" y2="115" stroke="#FFB800" stroke-opacity="0.4" stroke-dasharray="3 2"/>
        <line x1="132" y1="65" x2="132" y2="115" stroke="#FFB800" stroke-opacity="0.4" stroke-dasharray="3 2"/>
        <line x1="144" y1="65" x2="144" y2="115" stroke="#FFB800" stroke-opacity="0.4" stroke-dasharray="3 2"/>

        <!-- Oxygen Sensor Boss Port on Shell -->
        <circle cx="120" cy="55" r="5" fill="#38bdf8" stroke="#0284c7" stroke-width="1.5"/>

        <!-- Badge -->
        <rect x="12" y="12" width="112" height="20" rx="6" fill="#FF3B30" fill-opacity="0.15" stroke="#FF3B30" stroke-width="1"/>
        <text x="68" y="26" fill="#FF3B30" font-family="monospace" font-size="10" font-weight="bold" text-anchor="middle">CAT CONVERTER</text>
        <text x="228" y="26" fill="#FFB800" font-family="monospace" font-size="9" font-weight="bold" text-anchor="end">EURO 4/5 OEM</text>
      </svg>`;

    case "BRAKE_DISC":
      return `<svg viewBox="0 0 240 180" width="100%" height="100%" xmlns="http://www.w3.org/2000/svg" class="part-svg">
        <defs>
          <linearGradient id="rotor" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stop-color="#94a3b8"/>
            <stop offset="50%" stop-color="#475569"/>
            <stop offset="100%" stop-color="#1e293b"/>
          </linearGradient>
        </defs>
        <rect width="240" height="180" rx="16" fill="#070D1E" stroke="#1e293b" stroke-width="1.5"/>
        
        <!-- Ventilated Rotor Disc Face -->
        <circle cx="110" cy="95" r="62" fill="url(#rotor)" stroke="#cbd5e1" stroke-width="2"/>
        <circle cx="110" cy="95" r="52" fill="none" stroke="#64748b" stroke-width="1" stroke-dasharray="6 4"/>
        
        <!-- Cross-drilled cooling holes -->
        <circle cx="90" cy="65" r="2.5" fill="#070D1E"/>
        <circle cx="130" cy="65" r="2.5" fill="#070D1E"/>
        <circle cx="75" cy="95" r="2.5" fill="#070D1E"/>
        <circle cx="145" cy="95" r="2.5" fill="#070D1E"/>
        <circle cx="90" cy="125" r="2.5" fill="#070D1E"/>
        <circle cx="130" cy="125" r="2.5" fill="#070D1E"/>

        <!-- Center Wheel Hub & 5 Lug Studs -->
        <circle cx="110" cy="95" r="26" fill="#1e293b" stroke="#94a3b8" stroke-width="2"/>
        <circle cx="110" cy="95" r="12" fill="#070D1E" stroke="#00F0FF" stroke-width="1.5"/>
        <circle cx="110" cy="76" r="3.5" fill="#cbd5e1"/>
        <circle cx="127" cy="85" r="3.5" fill="#cbd5e1"/>
        <circle cx="121" cy="107" r="3.5" fill="#cbd5e1"/>
        <circle cx="99" cy="107" r="3.5" fill="#cbd5e1"/>
        <circle cx="93" cy="85" r="3.5" fill="#cbd5e1"/>

        <!-- Red High Performance Caliper -->
        <path d="M 142 45 C 175 60 178 120 148 140 L 160 120 C 168 105 168 85 155 65 Z" 
              fill="#FF3B30" stroke="#b91c1c" stroke-width="2"/>
        <rect x="155" y="75" width="22" height="38" rx="4" fill="#1e293b" stroke="#FF3B30" stroke-width="1.5"/>

        <!-- Badge -->
        <rect x="12" y="12" width="85" height="20" rx="6" fill="#00F0FF" fill-opacity="0.15" stroke="#00F0FF" stroke-width="1"/>
        <text x="54" y="26" fill="#00F0FF" font-family="monospace" font-size="10" font-weight="bold" text-anchor="middle">BRAKE ROTOR</text>
        <text x="228" y="26" fill="#10B981" font-family="monospace" font-size="9" font-weight="bold" text-anchor="end">VENTILATED DISC</text>
      </svg>`;

    default: // MAF / Engine sensor / Generic high-tech module
      return `<svg viewBox="0 0 240 180" width="100%" height="100%" xmlns="http://www.w3.org/2000/svg" class="part-svg">
        <defs>
          <linearGradient id="gen_metal" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stop-color="#334155"/>
            <stop offset="50%" stop-color="#1e293b"/>
            <stop offset="100%" stop-color="#0f172a"/>
          </linearGradient>
        </defs>
        <rect width="240" height="180" rx="16" fill="#070D1E" stroke="#1e293b" stroke-width="1.5"/>
        <path d="M 20 90 H 220 M 120 20 V 160" stroke="#00F0FF" stroke-opacity="0.1" stroke-dasharray="3 3"/>
        
        <!-- Precision Sensor Housing -->
        <rect x="65" y="48" width="110" height="84" rx="14" fill="url(#gen_metal)" stroke="#475569" stroke-width="2"/>
        <circle cx="120" cy="90" r="28" fill="#070D1E" stroke="#00F0FF" stroke-width="2"/>
        
        <!-- Sensor Probe Tip / Gold Pins -->
        <rect x="112" y="74" width="16" height="32" rx="3" fill="#FFB800"/>
        <line x1="116" y1="80" x2="124" y2="80" stroke="#78350f" stroke-width="1.5"/>
        <line x1="116" y1="90" x2="124" y2="90" stroke="#78350f" stroke-width="1.5"/>
        <line x1="116" y1="100" x2="124" y2="100" stroke="#78350f" stroke-width="1.5"/>

        <!-- Multi-pin Connector Port -->
        <rect x="155" y="70" width="30" height="40" rx="4" fill="#0f172a" stroke="#00F0FF" stroke-width="1.5"/>
        <circle cx="170" cy="80" r="2" fill="#00F0FF"/>
        <circle cx="170" cy="90" r="2" fill="#00F0FF"/>
        <circle cx="170" cy="100" r="2" fill="#00F0FF"/>

        <!-- Microchip Spec Label -->
        <rect x="75" y="58" width="35" height="14" rx="3" fill="#00F0FF" fill-opacity="0.15"/>
        <text x="92" y="68" fill="#00F0FF" font-family="monospace" font-size="8" font-weight="bold" text-anchor="middle">OEM SPEC</text>

        <!-- Badge -->
        <rect x="12" y="12" width="88" height="20" rx="6" fill="#00F0FF" fill-opacity="0.15" stroke="#00F0FF" stroke-width="1"/>
        <text x="56" y="26" fill="#00F0FF" font-family="monospace" font-size="10" font-weight="bold" text-anchor="middle">AUTO COMPONENT</text>
        <text x="228" y="26" fill="#10B981" font-family="monospace" font-size="9" font-weight="bold" text-anchor="end">GENUINE OEM</text>
      </svg>`;
  }
}
