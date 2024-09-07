import os
from playwright.sync_api import sync_playwright

USERNAME = os.getenv("LETTERBOXD_USERNAME", "default_username")

# Main function to scrape and clone the page
def clone_letterboxd():
    base_dir = 'data/html'
    os.makedirs(base_dir, exist_ok=True)  # Create base directory if it doesn't exist

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()

        # Loop through pages you want to clone
        for page_num in range(1, 4):  # Adjust the range as necessary
            url = f"https://letterboxd.com/{USERNAME}/films/reviews/page/{page_num}/"
            print(f"Cloning: {url}")
            page.goto(url)
            page.wait_for_load_state('networkidle')  # Wait for the page to fully load

            # Scroll down to trigger lazy loading
            page.evaluate("""() => {
                window.scrollTo(0, document.body.scrollHeight);
            }""")
            page.wait_for_timeout(2000)  # Add a slight delay to ensure everything loads

            # Get the full HTML content
            html_content = page.content()

            # Set up the directory structure for saving
            save_path = os.path.join(base_dir, USERNAME, 'films', 'reviews', 'page', str(page_num), 'index.html')
            os.makedirs(os.path.dirname(save_path), exist_ok=True)

            # Save the full HTML content without modifying any image URLs
            with open(save_path, 'w', encoding='utf-8') as f:
                f.write(html_content)
            print(f"HTML saved: {save_path}")

        browser.close()

if __name__ == "__main__":
    clone_letterboxd()
