import asyncio
import logging
from sqlmodel import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import sessionmaker
from app.db.session import engine
from app.models.tenant import Tenant
from app.models.contact import Contact

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

        # Check if contact exists
        statement = select(Contact).where(Contact.tenant_id == qc_tenant.id, Contact.name == "QCPD Station 1 (API Test)")
        result = await session.execute(statement)
        contact = result.scalar_one_or_none()

        if not contact:
            logger.info("Creating 'QCPD Station 1 (API Test)' Contact...")
            qc_contact = Contact(
                name="QCPD Station 1 (API Test)",
                phone_number="0917-111-2222",
                category="Police",
                priority=1,
                protocol="tel",
                tenant_id=qc_tenant.id
            )
            session.add(qc_contact)
            await session.commit()
            logger.info("Created QC contact.")
        else:
            logger.info("QC contact already exists.")

        # Expand test data to ensure UI changes are noticeable
        additional_contacts = [
            Contact(
                name="QC DRRMO Hotline",
                phone_number="122",
                category="Rescue",
                priority=10,
                protocol="tel",
                tenant_id=qc_tenant.id
            ),
            Contact(
                name="QC Fire Station",
                phone_number="02-8924-1111",
                category="Fire",
                priority=8,
                protocol="tel",
                tenant_id=qc_tenant.id
            ),
            Contact(
                name="QC Red Cross",
                phone_number="0918-123-4567",
                category="Medical",
                priority=7,
                protocol="tel",
                tenant_id=qc_tenant.id
            ),
            Contact(
                name="Barangay Santo Cristo Tanod (Viber)",
                phone_number="viber_sto_cristo",
                category="Barangay",
                priority=5,
                protocol="viber",
                tenant_id=qc_tenant.id
            )
        ]

        logger.info("Injecting additional test contacts...")
        for new_contact in additional_contacts:
            statement = select(Contact).where(Contact.tenant_id == qc_tenant.id, Contact.name == new_contact.name)
            result = await session.execute(statement)
            if not result.scalar_one_or_none():
                session.add(new_contact)
        
        await session.commit()
        logger.info("Additional QC contacts injected.")

if __name__ == "__main__":
    asyncio.run(seed_qc_data())
