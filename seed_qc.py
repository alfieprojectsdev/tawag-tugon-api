import asyncio
import logging
from sqlmodel import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import sessionmaker
from app.db.session import engine
from datetime import datetime
from app.models.tenant import Tenant
from app.models.contact import Contact
from app.models.news import News
from app.models.user import User
from app.core.security import get_password_hash

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

async def seed_qc_data():
    async_session = sessionmaker(
        engine, class_=AsyncSession, expire_on_commit=False
    )
    async with async_session() as session:
        # Check if qc tenant already exists
        statement = select(Tenant).where(Tenant.slug == "qc")
        result = await session.execute(statement)
        qc_tenant = result.scalar_one_or_none()
        
        if not qc_tenant:
            logger.info("Creating 'qc' Tenant...")
            qc_tenant = Tenant(
                name="Quezon City",
                slug="qc",
                primary_color="#0033A0",
                is_active=True
            )
            session.add(qc_tenant)
            await session.commit()
            await session.refresh(qc_tenant)
            logger.info(f"Created QC tenant with ID: {qc_tenant.id}")
        else:
            logger.info(f"QC tenant already exists with ID: {qc_tenant.id}")

        # Check if admin user exists
        statement = select(User).where(User.email == "admin@qc.gov.ph")
        result = await session.execute(statement)
        admin_user = result.scalar_one_or_none()

        if not admin_user:
            logger.info("Creating admin user...")
            new_user = User(
                email="admin@qc.gov.ph",
                hashed_password=get_password_hash("your_password"),
                role="admin",
                tenant_id=qc_tenant.id
            )
            session.add(new_user)
            await session.commit()
            logger.info("Created admin user 'admin@qc.gov.ph' with password 'your_password'.")
        else:
            logger.info("Admin user already exists.")

        # Verified QC / Metro Manila hotlines as of 2026. Landlines carry the
        # (02) area code + NTC 8-digit format so mobile dialing works as-is;
        # 3/5-digit hotlines are dialable verbatim. Higher priority = shown
        # first in the mobile directory.
        verified_contacts = [
            # -- Life-threatening emergencies first --
            ("National Emergency Hotline", "911", "Emergency", 100),
            ("QC Emergency Hotline (Helpline 122)", "122", "Emergency", 95),
            ("Philippine Red Cross", "143", "Medical", 90),
            ("QC Police District (QCPD)", "(02) 8925-8326", "Police", 85),
            ("QC Fire District", "(02) 8330-2344", "Fire", 80),
            ("QC DPOS Rescue", "(02) 8928-4396", "Rescue", 75),
            ("Red Cross - QC Chapter", "(02) 8403-1063", "Medical", 70),
            # -- Public safety / welfare --
            ("MMDA (Traffic & Road Emergencies)", "136", "Traffic", 60),
            ("Bantay Bata (Child Protection)", "163", "Social Welfare", 55),
            ("Barangay San Vicente Hall", "(02) 8441-5644", "Barangay", 50),
            # -- Utilities --
            ("Meralco (Power Outages)", "16211", "Utility", 30),
            ("Manila Water (24/7 Hotline)", "1627", "Utility", 25),
            ("PLDT Customer Service", "171", "Utility", 20),
        ]

        # Clean-slate reseed: drop this tenant's existing contacts so stale
        # test entries (fake numbers, outdated 7-digit landlines) never
        # survive into a demo.
        statement = select(Contact).where(Contact.tenant_id == qc_tenant.id)
        result = await session.execute(statement)
        for old_contact in result.scalars().all():
            await session.delete(old_contact)
        await session.commit()

        logger.info("Seeding %d verified QC contacts...", len(verified_contacts))
        for name, phone_number, category, priority in verified_contacts:
            session.add(Contact(
                name=name,
                phone_number=phone_number,
                category=category,
                priority=priority,
                protocol="tel",
                tenant_id=qc_tenant.id
            ))

        await session.commit()
        logger.info("Verified QC contacts seeded.")

        # QC program news, condensed from quezoncity.gov.ph (text only).
        # Matches the bundled demo data in tawag_tugon_app/lib/seed_data.dart;
        # the app dedupes on source_url when syncing.
        qc_news = [
            (
                "QCitizen ID: One Card for All City Services",
                "The Quezon City Government's QCitizen ID is a unified identification "
                "system designed to give the city a complete and accurate database of "
                "its residents, enabling personalized services and better allocation "
                "of resources to rightful beneficiaries.\n\n"
                "Cardholders get easier and faster access to city services and "
                "programs, exclusive benefits and special discounts on city programs, "
                "and discounts from partner merchants. The ID is available as a "
                "physical card or a mobile application with a unique ID number.\n\n"
                "Four categories may apply: residents, Persons with Disabilities "
                "(PWD), senior citizens, and non-residents studying or working in "
                "Quezon City. Apply online through the QC e-Services platform or via "
                "walk-in. As of January 2026 the program counts 1,561,380 active "
                "cardholders since its establishment in 2021. For assistance, contact "
                "the QC ID team via Facebook or call HELPLINE 122.",
                "https://quezoncity.gov.ph/program/qcitizen-id/",
                datetime(2026, 7, 12, 9, 0),
            ),
            (
                "Nano-Enterprise Registration: Tax-Free Permits for Sari-Sari Stores and Carinderia",
                "The Quezon City Government, through the Small Business and "
                "Cooperatives Development and Promotions Office (SBCDPO) and the "
                "Business Permits and Licensing Department (BPLD), launched the "
                "Nano-Enterprise Registration Program to support home-based and "
                "community-based livelihoods in the city, including sari-sari stores "
                "and carinderia.\n\n"
                "The program covers self-employed individuals or sole proprietorships "
                "with an asset size not exceeding PHP 50,000 and annual gross sales "
                "receipts not exceeding PHP 250,000.\n\n"
                "Registered nano-enterprises are exempt from local business tax and "
                "regulatory fees, and get priority consideration for grants, "
                "subsidies, loans, workshops, seminars, and mentorship. Businesses "
                "affected by disasters such as fires and floods become eligible for "
                "capital assistance.\n\n"
                "Register by submitting the needed documents via QC e-Services "
                "Business One-Stop-Shop. As of March 2026, 496 nano-enterprises have "
                "registered.",
                "https://quezoncity.gov.ph/program/nano-enterprise-registration-program/",
                datetime(2026, 7, 10, 9, 0),
            ),
            (
                "Start-Up QC: Equity-Free Grants for Professionals and Business",
                "Through the Local Economic Development and Investment Promotions "
                "Office (LEDIPO), the Quezon City Government runs the Start-Up QC "
                "Program to inspire and empower QCitizens to develop business models "
                "that address social issues and concerns.\n\n"
                "Participants progress through three phases — evaluation, business "
                "development, and product development — with curated activities to "
                "improve, mentor, and finalize business models from conceptualization "
                "to execution. Ventures that complete all phases receive equity-free "
                "grants for execution.\n\n"
                "The program welcomes both professional and business categories and "
                "has completed four cohorts as of April 2026. To apply, coordinate "
                "with LEDIPO or consult the FAQ on the QC Government website; follow "
                "the official Start-Up QC and QC Gov Facebook pages for updates.",
                "https://quezoncity.gov.ph/program/start-up-qc-program/",
                datetime(2026, 7, 8, 9, 0),
            ),
            (
                "Start-Up QC Student Competition: Up to P100,000 for Student Founders",
                "The Quezon City Government, via the QC Local Economic Development "
                "and Investment Promotions Office, extends startup opportunities to "
                "students from schools and universities citywide. Participants pitch "
                "innovative business proposals that help the city's key sectors, "
                "such as agriculture, finance, education, health, information "
                "technology, culture, and arts.\n\n"
                "Each cohort (\"Squad\") receives training, mentorship, and networking "
                "activities facilitated by the local government. Prizes: First Place "
                "P100,000; Second Place P75,000; Third Place P50,000; Gold P35,000; "
                "Silver P25,000; Bronze P15,000.\n\n"
                "As of April 2026, Squad 1 had 27 awardees and Squad 2 had 29, with "
                "the Squad 3 competition now open. Watch the official Start-Up "
                "Facebook page and QC Gov FB page for announcements, or contact "
                "QC LEDIPO for more information.",
                "https://quezoncity.gov.ph/program/start-up-student-competition/",
                datetime(2026, 7, 6, 9, 0),
            ),
            (
                "No Woman Left Behind: Health, Education, and Livelihood for Female PDLs",
                "Through the Quezon Gender and Development Council and the Office of "
                "the City Mayor, the No Woman Left Behind program improves welfare "
                "for female Persons Deprived of Liberty (PDLs) during and after "
                "detention.\n\n"
                "Healthcare: medical services including lab work, pregnancy tests, "
                "and vaccines — 19,376 medical interventions performed since 2021 "
                "(as of March 2026).\n\n"
                "Education: in partnership with Quezon City University, participants "
                "access basic and higher education and the Alternative Learning "
                "System; 353 PDLs have graduated from Elementary-SHS and 43 with a "
                "BS in Entrepreneurship.\n\n"
                "Livelihood: capital assistance, the Vote to Tote upcycling campaign, "
                "and the Cup of Joy coffee shop with barista training — 291 "
                "participants to date. After care: 162 released PDLs have received "
                "capital assistance for reintegration.\n\n"
                "For details, contact the QC GAD Council.",
                "https://quezoncity.gov.ph/program/no-woman-left-behind-2/",
                datetime(2026, 7, 4, 9, 0),
            ),
        ]

        logger.info("Seeding %d QC news articles...", len(qc_news))
        for title, content, source_url, published_date in qc_news:
            statement = select(News).where(
                News.tenant_id == qc_tenant.id, News.source_url == source_url
            )
            result = await session.execute(statement)
            if not result.scalar_one_or_none():
                session.add(News(
                    title=title,
                    content=content,
                    source_url=source_url,
                    published_date=published_date,
                    tenant_id=qc_tenant.id,
                ))

        await session.commit()
        logger.info("QC news articles seeded.")

if __name__ == "__main__":
    asyncio.run(seed_qc_data())
