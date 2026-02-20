from sqlmodel import Session
from app.db.session import engine, init_db
from app.models.tenant import Tenant
from app.models.contact import Contact

def seed_data():
    init_db()
    with Session(engine) as session:
        # Check if tenant exists
        existing_tenant = session.query(Tenant).filter(Tenant.slug == "barangay-la-paz").first()
        if not existing_tenant:
            tenant = Tenant(
                name="Barangay La Paz",
                slug="barangay-la-paz",
                primary_color="#FF0000",
                is_active=True
            )
            session.add(tenant)
            session.commit()
            session.refresh(tenant)
            print(f"Created tenant: {tenant.name}")
            
            contact = Contact(
                name="Police Station",
                phone_number="911",
                category="Police",
                tenant_id=tenant.id
            )
            session.add(contact)
            session.commit()
            print("Created contact: Police Station")
        else:
            print("Tenant already exists")

if __name__ == "__main__":
    seed_data()
