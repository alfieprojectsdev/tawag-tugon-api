import httpx
from bs4 import BeautifulSoup
from sqlmodel import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.news import News
import logging

logger = logging.getLogger(__name__)

class ScraperService:
    async def fetch_and_store_news(self, session: AsyncSession, tenant_id: int, url: str) -> News | None:
        """
        Fetches news from a given URL, parses basic HTML, and stores it in the database
        if it doesn't already exist.
        """
        try:
            # 1. Fetch the HTML
            headers = {
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
                "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
                "Accept-Language": "en-US,en;q=0.5",
            }
            async with httpx.AsyncClient(follow_redirects=True, headers=headers) as client:
                response = await client.get(url, timeout=10.0)
                response.raise_for_status()
                html = response.text
        except Exception as e:
            logger.error(f"Failed to fetch URL {url}: {e}")
            return None

        # 2. Parse the HTML
        soup = BeautifulSoup(html, "html.parser")
        
        # Try to find the main article container, fallback to body
        article = soup.find("article") or soup.find("main") or soup.body
        if not article:
            logger.error(f"Could not find main content in {url}")
            return None

        # 3. Extract Title (h1 or h2)
        title_tag = article.find(["h1", "h2"])
        title = title_tag.get_text(strip=True) if title_tag else "Untitled Announcement"

        # 4. Extract Content (all p tags)
        paragraphs = article.find_all("p")
        content = "\n\n".join([p.get_text(strip=True) for p in paragraphs if p.get_text(strip=True)])
        
        if not content:
            # Fallback if no <p> tags are found, just grab all text
            content = article.get_text(separator="\n\n", strip=True)
            
        # 5. Deduplication Check
        # Validate if the news item already exists (matching URL or Title for the same tenant)
        statement = select(News).where(
            (News.tenant_id == tenant_id) & 
            ((News.source_url == url) | (News.title == title))
        )
        result = await session.execute(statement)
        existing_news = result.scalar_one_or_none()

        if existing_news:
            logger.info(f"News item already exists for tenant {tenant_id}: {title}")
            return existing_news

        # 6. Store new News item
        new_news = News(
            title=title[:255], # Safety cutoff for title length
            content=content,
            source_url=url,
            tenant_id=tenant_id
        )
        
        session.add(new_news)
        await session.commit()
        await session.refresh(new_news)
        
        logger.info(f"Successfully scraped and stored: {title}")
        return new_news

scraper_service = ScraperService()
