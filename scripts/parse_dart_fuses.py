# -*- coding: utf-8 -*-
import json
import re
import os

with open("kashif_mobile/lib/data/repositories/car_fuse_repository.dart", "r", encoding="utf-8") as f:
    text = f.read()

def parse_balanced(text, start_index):
    """Find matching closing parenthesis from start_index where text[start_index] == '('"""
    depth = 0
    in_string = False
    quote_char = None
    escape = False
    for i in range(start_index, len(text)):
        ch = text[i]
        if escape:
            escape = False
            continue
        if ch == '\\':
            escape = True
            continue
        if in_string:
            if ch == quote_char:
                in_string = False
            continue
        if ch in ("'", '"'):
            in_string = True
            quote_char = ch
            continue
        if ch == '(':
            depth += 1
        elif ch == ')':
            depth -= 1
            if depth == 0:
                return text[start_index+1:i], i
    return text[start_index+1:], len(text)

# Let's locate all CarVehicleModel
car_indices = [m.start() for m in re.finditer(r'\bCarVehicleModel\s*\(', text)]
cars = []

for idx in car_indices:
    car_content, end_idx = parse_balanced(text, text.find('(', idx))
    
    # car fields
    cid = re.search(r"id:\s*['\"]([^'\"]+)['\"]", car_content)
    make = re.search(r"make:\s*['\"]([^'\"]+)['\"]", car_content)
    makeArabic = re.search(r"makeArabic:\s*['\"]([^'\"]+)['\"]", car_content)
    model = re.search(r"model:\s*['\"]([^'\"]+)['\"]", car_content)
    modelArabic = re.search(r"modelArabic:\s*['\"]([^'\"]+)['\"]", car_content)
    yearRange = re.search(r"yearRange:\s*['\"]([^'\"]+)['\"]", car_content)
    bodyType = re.search(r"bodyType:\s*['\"]([^'\"]+)['\"]", car_content)
    obdLocation = re.search(r"obdLocation:\s*['\"]([^'\"]+)['\"]", car_content)
    
    if not cid or not make or not model:
        continue
        
    car_obj = {
        "id": cid.group(1),
        "make": make.group(1),
        "makeArabic": makeArabic.group(1) if makeArabic else make.group(1),
        "model": model.group(1),
        "modelArabic": modelArabic.group(1) if modelArabic else model.group(1),
        "yearRange": yearRange.group(1) if yearRange else "",
        "bodyType": bodyType.group(1) if bodyType else "",
        "obdLocation": obdLocation.group(1) if obdLocation else "",
        "fuseBoxes": []
    }
    
    # Locate VehicleFuseBox inside this car
    box_indices = [m.start() for m in re.finditer(r'\bVehicleFuseBox\s*\(', car_content)]
    for b_idx in box_indices:
        b_content, _ = parse_balanced(car_content, car_content.find('(', b_idx))
        bid = re.search(r"id:\s*['\"]([^'\"]+)['\"]", b_content)
        bname = re.search(r"nameArabic:\s*['\"]([^'\"]+)['\"]", b_content)
        bloc = re.search(r"locationType:\s*FuseBoxLocationType\.(\w+)", b_content)
        bdet = re.search(r"detailedLocationArabic:\s*['\"]([^'\"]+)['\"]", b_content)
        bacc = re.search(r"accessInstructions:\s*['\"]([^'\"]+)['\"]", b_content)
        bcover = re.search(r"realisticCoverNote:\s*['\"]([^'\"]+)['\"]", b_content)
        bcard = re.search(r"cardPartNumber:\s*['\"]([^'\"]+)['\"]", b_content)
        btab = re.search(r"hasPullTab:\s*(true|false)", b_content)
        
        if not bid or not bname:
            continue
            
        box_obj = {
            "id": bid.group(1),
            "nameArabic": bname.group(1),
            "locationType": bloc.group(1) if bloc else "engineBay",
            "detailedLocationArabic": bdet.group(1) if bdet else "",
            "accessInstructions": bacc.group(1) if bacc else "",
            "realisticCoverNote": bcover.group(1) if bcover else "",
            "cardPartNumber": bcard.group(1) if bcard else "",
            "hasPullTab": btab.group(1) == "true" if btab else False,
            "equipmentMappings": [],
            "slots": []
        }
        
        # Equipment mappings
        eq_indices = [m.start() for m in re.finditer(r'\bEquipmentFuseMapping\s*\(', b_content)]
        for eq_i in eq_indices:
            eq_c, _ = parse_balanced(b_content, b_content.find('(', eq_i))
            eq_en = re.search(r"equipmentEnglish:\s*['\"]([^'\"]+)['\"]", eq_c)
            eq_ar = re.search(r"equipmentArabic:\s*['\"]([^'\"]+)['\"]", eq_c)
            eq_cat = re.search(r"category:\s*['\"]([^'\"]+)['\"]", eq_c)
            eq_fuses = re.search(r"fuseNumbers:\s*\[([\d\s,]+)\]", eq_c)
            fuses = [int(x.strip()) for x in eq_fuses.group(1).split(",") if x.strip().isdigit()] if eq_fuses else []
            if eq_en and eq_ar:
                box_obj["equipmentMappings"].append({
                    "equipmentEnglish": eq_en.group(1),
                    "equipmentArabic": eq_ar.group(1),
                    "category": eq_cat.group(1) if eq_cat else "general",
                    "fuseNumbers": fuses
                })
                
        # Slots
        slot_indices = [m.start() for m in re.finditer(r'\bFuseSlot\s*\(', b_content)]
        for s_i in slot_indices:
            sc, _ = parse_balanced(b_content, b_content.find('(', s_i))
            s_id = re.search(r"slotId:\s*['\"]([^'\"]+)['\"]", sc)
            s_label = re.search(r"label:\s*['\"]([^'\"]+)['\"]", sc)
            s_nameAr = re.search(r"nameArabic:\s*['\"]([^'\"]+)['\"]", sc)
            s_rating = re.search(r"ratingAmps:\s*(\d+(?:\.\d+)?)", sc)
            s_descAr = re.search(r"descriptionArabic:\s*['\"]([^'\"]+)['\"]", sc)
            s_testingTip = re.search(r"testingTip:\s*['\"]([^'\"]+)['\"]", sc)
            s_isRelay = re.search(r"isRelay:\s*(true|false)", sc)
            s_gridRow = re.search(r"gridRow:\s*(\d+)", sc)
            s_gridCol = re.search(r"gridCol:\s*(\d+)", sc)
            
            symptoms = []
            sym_match = re.search(r"symptoms:\s*\[([\s\S]*?)\]", sc)
            if sym_match:
                for s in re.finditer(r"['\"]([^'\"]+)['\"]", sym_match.group(1)):
                    symptoms.append(s.group(1))
                    
            dtcs = []
            dtc_match = re.search(r"associatedDTCs:\s*\[([\s\S]*?)\]", sc)
            if dtc_match:
                for s in re.finditer(r"['\"]([^'\"]+)['\"]", dtc_match.group(1)):
                    dtcs.append(s.group(1))
                    
            if s_id:
                box_obj["slots"].append({
                    "slotId": s_id.group(1),
                    "label": s_label.group(1) if s_label else s_id.group(1),
                    "nameArabic": s_nameAr.group(1) if s_nameAr else "",
                    "ratingAmps": float(s_rating.group(1)) if s_rating else 15.0,
                    "descriptionArabic": s_descAr.group(1) if s_descAr else "",
                    "testingTip": s_testingTip.group(1) if s_testingTip else "",
                    "isRelay": s_isRelay.group(1) == "true" if s_isRelay else False,
                    "gridRow": int(s_gridRow.group(1)) if s_gridRow else 0,
                    "gridCol": int(s_gridCol.group(1)) if s_gridCol else 0,
                    "symptoms": symptoms,
                    "associatedDTCs": dtcs
                })
        car_obj["fuseBoxes"].append(box_obj)
    cars.append(car_obj)

total_slots = sum(sum(len(b["slots"]) for b in c["fuseBoxes"]) for c in cars)
total_eq = sum(sum(len(b["equipmentMappings"]) for b in c["fuseBoxes"]) for c in cars)
print(f"Extracted {len(cars)} cars, total {total_slots} slots, total {total_eq} equipment mappings.")

os.makedirs("public/data", exist_ok=True)
with open("public/data/car_fuses.json", "w", encoding="utf-8") as out:
    json.dump(cars, out, ensure_ascii=False, indent=2)

print("Saved to public/data/car_fuses.json successfully!")
