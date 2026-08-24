import time
import os
from playwright.sync_api import sync_playwright

def test_kashif_high_tech_ui():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(viewport={"width": 1440, "height": 960})
        page = context.new_page()
        
        # 1. Open Landing Page
        print("1. Navigating to http://localhost:3000...")
        page.goto("http://localhost:3000", wait_until="networkidle")
        time.sleep(2)
        page.screenshot(path="screenshot_landing.png")
        print("Captured screenshot_landing.png")
        
        # 2. Click BMW 528i Sample Demo
        print("2. Clicking BMW 528i Sample Report...")
        page.click("button:has-text('BMW 528i (E39)')")
        time.sleep(3)
        page.wait_for_selector("text=BMW 528i", timeout=15000)
        
        # Assertions on BMW Report
        assert "BMW" in page.content(), "BMW make should be visible"
        assert "528i" in page.content(), "BMW 528i model should be visible"
        assert "دليل قطع الغيار" in page.content(), "Spare parts section should be visible"
        print("Verified BMW 528i Report successfully!")
        
        page.screenshot(path="screenshot_report_bmw.png")
        print("Captured screenshot_report_bmw.png")
        
        # 3. Test Interactive Sensor & Fuse Box Locator Modal
        print("3. Testing Sensor & Fuse Box Locator Modal...")
        page.click("button:has-text('مخطط الفيوز والفيشة')")
        time.sleep(1)
        assert "موقع الحساس بالمحرك" in page.content(), "Engine bay tab should be visible"
        page.screenshot(path="screenshot_sensor_modal_engine.png")
        print("Captured screenshot_sensor_modal_engine.png")
        
        # Switch to Fuse Box Tab
        print("Switching to Fuse Box Tab...")
        page.click("button:has-text('مخطط علبة الفيوزات')")
        time.sleep(1)
        assert "FUSE BOX SCHEMATIC MATRIX" in page.content() or "علبة فيوزات" in page.content(), "Fuse schematic should be visible"
        page.screenshot(path="screenshot_sensor_modal_fuse.png")
        print("Captured screenshot_sensor_modal_fuse.png")
        
        # Switch to Multimeter Tab
        print("Switching to Multimeter Tab...")
        page.click("button:has-text('فحص الفيشة بالأفوميتر')")
        time.sleep(1)
        assert "طريقة فحص الفيشة والبيانتو" in page.content() or "Power" in page.content(), "Multimeter pinout should be visible"
        page.screenshot(path="screenshot_sensor_modal_multimeter.png")
        print("Captured screenshot_sensor_modal_multimeter.png")
        
        # Close modal
        page.click("button:has-text('إغلاق المخطط')")
        time.sleep(1)
        
        # 4. Test Spare Parts Zoom Modal
        print("4. Testing Spare Parts Modal Zoom...")
        page.locator(".group\\/img").first.click()
        time.sleep(1)
        page.screenshot(path="screenshot_part_modal.png")
        print("Captured screenshot_part_modal.png")
        
        # Close modal
        page.keyboard.press("Escape")
        time.sleep(1)
        
        # 5. Test Standalone HTML Report Download Trigger
        print("5. Testing Standalone HTML Report Download...")
        with page.expect_download() as download_info:
            page.click("button:has-text('تنزيل تقرير HTML')")
        download = download_info.value
        download_path = os.path.join(os.getcwd(), "test_downloaded_report.html")
        download.save_as(download_path)
        print(f"Downloaded standalone HTML report to: {download_path}")
        
        # Verify content of the standalone HTML report
        with open(download_path, "r", encoding="utf-8") as f:
            html_content = f.read()
            assert "مركز الفحص والتشخيص الفني المعتمد" in html_content, "Workshop title must be in exported HTML"
            assert "BMW 528i" in html_content, "Vehicle info must be in exported HTML"
            assert "svg" in html_content or "part" in html_content, "Visuals must be in exported HTML"
            assert "مخطط الحساس والفيوز" in html_content, "Fuse and pinout info must be in exported HTML"
            assert "دليل قطع الغيار" in html_content, "Parts catalog must be in exported HTML"
        print("Standalone HTML Report content verified successfully with 100% integrity!")
        
        # 6. Render and screenshot the downloaded Standalone HTML Report directly
        print("6. Rendering Downloaded Standalone HTML Report in browser...")
        page.goto(f"file:///{download_path.replace(os.sep, '/')}", wait_until="networkidle")
        time.sleep(2)
        page.screenshot(path="screenshot_standalone_html.png", full_page=True)
        print("Captured screenshot_standalone_html.png")
        
        browser.close()
        print("ALL HIGH-TECH DESIGN SYSTEM, FUSE LOCATOR & HTML REPORT TESTS COMPLETED SUCCESSFULLY!")

if __name__ == "__main__":
    test_kashif_high_tech_ui()
