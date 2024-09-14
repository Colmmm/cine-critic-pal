import os
import re
from urllib.parse import urljoin, urlparse
from playwright.sync_api import sync_playwright, TimeoutError

USERNAME = os.getenv("LETTERBOXD_USERNAME", "default_username")

BASE_DIR = 'data/html'
REVIEW_PAGES_URL = f"https://letterboxd.com/{USERNAME}/films/reviews/page/"
NUMBER_OF_PAGES = 3  # Adjust based on the number of review pages you want to scrape

# Helper function to save HTML content to a specific path
def save_html(content, save_path):
    os.makedirs(os.path.dirname(save_path), exist_ok=True)
    with open(save_path, 'w', encoding='utf-8') as f:
        f.write(content)

# Updated function to handle the consent popup
def handle_consent_popup(page):
    # Selectors for the popup and buttons
    consent_popup_selector = 'body > div.fc-consent-root.__web-inspector-hide-shortcut__'
    consent_button_selector = 'body > div.fc-consent-root.__web-inspector-hide-shortcut__ > div.fc-dialog-container > div.fc-dialog.fc-choice-dialog > div.fc-footer-buttons-container > div.fc-footer-buttons > button.fc-button.fc-cta-do-not-consent.fc-secondary-button'

    try:
        # Wait for the popup
        page.wait_for_selector(consent_popup_selector, timeout=10000)
        
        # Option 1: Try to click the 'Do not consent' button
        try:
            consent_button = page.query_selector(consent_button_selector)
            if consent_button:
                consent_button.click()
                page.wait_for_load_state('networkidle')
                print("Consent dismissed.")
        except TimeoutError:
            print("No consent button found or timeout on clicking.")
        
        # Option 2: Remove the popup directly if clicking doesn't work
        try:
            popup = page.query_selector(consent_popup_selector)
            if popup:
                popup.evaluate("el => el.remove()")  # Remove the popup
                print("Popup removed.")
        except Exception as e:
            print(f"Error removing popup: {e}")
            
    except TimeoutError:
        print("No consent popup found or timeout.")

def clone_letterboxd():
    os.makedirs(BASE_DIR, exist_ok=True)
    visited_urls = set()  # To track visited URLs

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()

        # Scrape review page URLs
        for i in range(1, NUMBER_OF_PAGES + 1):
            review_page_url = f"{REVIEW_PAGES_URL}{i}/"
            print(f"Cloning review page: {review_page_url}")
            page.goto(review_page_url)
            handle_consent_popup(page)
            page.wait_for_load_state('networkidle')

            # Save review page HTML
            html_content = page.content()
            save_path = os.path.join(BASE_DIR, 'films', 'reviews', f'page_{i}', 'index.html')
            save_html(html_content, save_path)
            print(f"HTML saved: {save_path}")

            # Extract individual review URLs
            review_links = page.query_selector_all('a')
            for link in review_links:
                href = link.get_attribute('href')
                if href and 'film/' in href:
                    full_url = urljoin(review_page_url, href)
                    if full_url not in visited_urls:
                        visited_urls.add(full_url)
                        print(f"Found review URL: {full_url}")

        # Scrape individual review pages
        for review_url in visited_urls:
            print(f"Cloning individual review page: {review_url}")
            try:
                page.goto(review_url)
                handle_consent_popup(page)
                page.wait_for_load_state('networkidle')
                handle_consent_popup(page)

                # Save individual review page HTML
                html_content = page.content()
                parsed_url = urlparse(review_url)
                path_parts = parsed_url.path.strip('/').split('/')
                save_path = os.path.join(BASE_DIR, *path_parts, 'index.html')
                save_html(html_content, save_path)
                print(f"HTML saved: {save_path}")
            except Exception as e:
                print(f"Error while processing {review_url}: {e}")

        browser.close()

if __name__ == "__main__":
    clone_letterboxd()
