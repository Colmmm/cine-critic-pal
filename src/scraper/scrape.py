import os
from urllib.parse import urljoin, urlparse
from playwright.sync_api import sync_playwright

USERNAME = os.getenv("LETTERBOXD_USERNAME", "aruuuu_ainosuke")
BASE_DIR = 'data/html'
REVIEW_PAGES_URL = f"https://letterboxd.com/{USERNAME}/films/reviews/"
NUMBER_OF_PAGES = 3  # Adjust based on the number of review pages you want to scrape

# Helper function to save HTML content to a specific path
def save_html(content, save_path):
    os.makedirs(os.path.dirname(save_path), exist_ok=True)
    with open(save_path, 'w', encoding='utf-8') as f:
        f.write(content)


def scroll_page(page):
    # Scroll down the page in increments to trigger lazy-loaded content
    last_height = page.evaluate('document.body.scrollHeight')
    while True:
        page.evaluate('window.scrollTo(0, document.body.scrollHeight)')
        page.wait_for_timeout(1000)  # Wait for new content to load
        new_height = page.evaluate('document.body.scrollHeight')
        if new_height == last_height:
            break
        last_height = new_height

def clone_letterboxd():
    os.makedirs(BASE_DIR, exist_ok=True)
    visited_urls = set()  # To track visited URLs

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()

        # Scrape review page URLs
        for i in range(1, NUMBER_OF_PAGES + 1):
            review_page_url = REVIEW_PAGES_URL if i == 1 else f"{REVIEW_PAGES_URL}page/{i}/"
            print(f"Cloning review page: {review_page_url}")
            page.goto(review_page_url)
            page.wait_for_load_state('networkidle')

            # Scroll to trigger lazy loading
            scroll_page(page)

            # Save review page HTML
            save_path = os.path.join(BASE_DIR, USERNAME, 'films', 'reviews') if i == 1 else os.path.join(BASE_DIR, USERNAME, 'films', 'reviews', 'page', str(i))
            save_html(page.content(), os.path.join(save_path, 'index.html'))
            print(f"HTML saved: {save_path}/index.html")

            # Extract individual review URLs
            review_links = page.query_selector_all('a')
            for link in review_links:
                href = link.get_attribute('href')
                if href and f'/{USERNAME}/film/' in href:
                    full_url = urljoin(review_page_url, href)
                    if full_url not in visited_urls:
                        visited_urls.add(full_url)
                        print(f"Found review URL: {full_url}")

        # Scrape individual review pages
        for review_url in visited_urls:
            print(f"Cloning individual review page: {review_url}")
            page.goto(review_url)
            page.wait_for_load_state('networkidle')

            # Save individual review page HTML
            parsed_url = urlparse(review_url)
            film_slug = parsed_url.path.strip('/').split('/')[-1]
            save_path = os.path.join(BASE_DIR, USERNAME, 'film', film_slug)
            save_html(page.content(), os.path.join(save_path, 'index.html'))
            print(f"HTML saved: {save_path}/index.html")

        browser.close()

if __name__ == "__main__":
    clone_letterboxd()
