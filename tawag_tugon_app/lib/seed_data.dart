/// Bundled demo data for Quezon City (tenant_id 1), baked into the on-device
/// database so the app is fully populated on first launch with no network
/// sync required. A later sync against the API updates these rows in place
/// (news dedupes on source_url) rather than duplicating them.
///
/// Contacts: verified QC / Metro Manila hotlines as of 2026. Landlines carry
/// the (02) area code + NTC 8-digit format so mobile dialing works as-is.
/// News: condensed from the linked quezoncity.gov.ph program pages.
library;

const List<Map<String, dynamic>> seedContacts = [
  {
    'name': 'National Emergency Hotline',
    'phone_number': '911',
    'category': 'Emergency',
    'priority': 100,
    'protocol': 'tel',
    'tenant_id': 1,
  },
  {
    'name': 'QC Emergency Hotline (Helpline 122)',
    'phone_number': '122',
    'category': 'Emergency',
    'priority': 95,
    'protocol': 'tel',
    'tenant_id': 1,
  },
  {
    'name': 'Emergency Operations Center (Landline)',
    'phone_number': '(02) 8988-4242 local 8038',
    'category': 'Emergency',
    'priority': 94,
    'protocol': 'tel',
    'tenant_id': 1,
  },
  {
    'name': 'Emergency Operations Center (Mobile 1)',
    'phone_number': '0947-885-9929',
    'category': 'Emergency',
    'priority': 93,
    'protocol': 'tel',
    'tenant_id': 1,
  },
  {
    'name': 'Emergency Operations Center (Mobile 2)',
    'phone_number': '0947-884-7498',
    'category': 'Emergency',
    'priority': 92,
    'protocol': 'tel',
    'tenant_id': 1,
  },
  {
    'name': 'Philippine Red Cross',
    'phone_number': '143',
    'category': 'Medical',
    'priority': 90,
    'protocol': 'tel',
    'tenant_id': 1,
  },
  {
    'name': 'QC Police District (QCPD)',
    'phone_number': '(02) 8925-8326',
    'category': 'Police',
    'priority': 85,
    'protocol': 'tel',
    'tenant_id': 1,
  },
  {
    'name': 'QC Fire District',
    'phone_number': '(02) 8330-2344',
    'category': 'Fire',
    'priority': 80,
    'protocol': 'tel',
    'tenant_id': 1,
  },
  {
    'name': 'QC DPOS Rescue',
    'phone_number': '(02) 8928-4396',
    'category': 'Rescue',
    'priority': 75,
    'protocol': 'tel',
    'tenant_id': 1,
  },
  {
    'name': 'Red Cross - QC Chapter',
    'phone_number': '(02) 8403-1063',
    'category': 'Medical',
    'priority': 70,
    'protocol': 'tel',
    'tenant_id': 1,
  },
  {
    'name': 'MMDA (Traffic & Road Emergencies)',
    'phone_number': '136',
    'category': 'Traffic',
    'priority': 60,
    'protocol': 'tel',
    'tenant_id': 1,
  },
  {
    'name': 'Bantay Bata (Child Protection)',
    'phone_number': '163',
    'category': 'Social Welfare',
    'priority': 55,
    'protocol': 'tel',
    'tenant_id': 1,
  },
  {
    'name': 'Barangay San Vicente Hall',
    'phone_number': '(02) 8523-9330',
    'category': 'Barangay',
    'priority': 50,
    'protocol': 'tel',
    'tenant_id': 1,
  },
  {
    'name': 'Meralco (Power Outages)',
    'phone_number': '16211',
    'category': 'Utility',
    'priority': 30,
    'protocol': 'tel',
    'tenant_id': 1,
  },
  {
    'name': 'Manila Water (24/7 Hotline)',
    'phone_number': '1627',
    'category': 'Utility',
    'priority': 25,
    'protocol': 'tel',
    'tenant_id': 1,
  },
  {
    'name': 'PLDT Customer Service',
    'phone_number': '171',
    'category': 'Utility',
    'priority': 20,
    'protocol': 'tel',
    'tenant_id': 1,
  },
];

const List<Map<String, dynamic>> seedNews = [
  {
    'title': 'QCitizen ID: One Card for All City Services',
    'content':
        'The Quezon City Government\'s QCitizen ID is a unified identification '
        'system designed to give the city a complete and accurate database of '
        'its residents, enabling personalized services and better allocation '
        'of resources to rightful beneficiaries.\n\n'
        'Cardholders get easier and faster access to city services and '
        'programs, exclusive benefits and special discounts on city programs, '
        'and discounts from partner merchants. The ID is available as a '
        'physical card or a mobile application with a unique ID number.\n\n'
        'Four categories may apply: residents, Persons with Disabilities '
        '(PWD), senior citizens, and non-residents studying or working in '
        'Quezon City. Apply online through the QC e-Services platform or via '
        'walk-in. As of January 2026 the program counts 1,561,380 active '
        'cardholders since its establishment in 2021. For assistance, contact '
        'the QC ID team via Facebook or call HELPLINE 122.',
    'source_url': 'https://quezoncity.gov.ph/program/qcitizen-id/',
    'published_date': '2026-07-12T09:00:00',
    'tenant_id': 1,
  },
  {
    'title': 'Nano-Enterprise Registration: Tax-Free Permits for Sari-Sari '
        'Stores and Carinderia',
    'content':
        'The Quezon City Government, through the Small Business and '
        'Cooperatives Development and Promotions Office (SBCDPO) and the '
        'Business Permits and Licensing Department (BPLD), launched the '
        'Nano-Enterprise Registration Program to support home-based and '
        'community-based livelihoods in the city, including sari-sari stores '
        'and carinderia.\n\n'
        'The program covers self-employed individuals or sole proprietorships '
        'with an asset size not exceeding PHP 50,000 and annual gross sales '
        'receipts not exceeding PHP 250,000.\n\n'
        'Registered nano-enterprises are exempt from local business tax and '
        'regulatory fees, and get priority consideration for grants, '
        'subsidies, loans, workshops, seminars, and mentorship. Businesses '
        'affected by disasters such as fires and floods become eligible for '
        'capital assistance.\n\n'
        'Register by submitting the needed documents via QC e-Services '
        'Business One-Stop-Shop. As of March 2026, 496 nano-enterprises have '
        'registered.',
    'source_url':
        'https://quezoncity.gov.ph/program/nano-enterprise-registration-program/',
    'published_date': '2026-07-10T09:00:00',
    'tenant_id': 1,
  },
  {
    'title': 'Start-Up QC: Equity-Free Grants for Professionals and Business',
    'content':
        'Through the Local Economic Development and Investment Promotions '
        'Office (LEDIPO), the Quezon City Government runs the Start-Up QC '
        'Program to inspire and empower QCitizens to develop business models '
        'that address social issues and concerns.\n\n'
        'Participants progress through three phases — evaluation, business '
        'development, and product development — with curated activities to '
        'improve, mentor, and finalize business models from conceptualization '
        'to execution. Ventures that complete all phases receive equity-free '
        'grants for execution.\n\n'
        'The program welcomes both professional and business categories and '
        'has completed four cohorts as of April 2026. To apply, coordinate '
        'with LEDIPO or consult the FAQ on the QC Government website; follow '
        'the official Start-Up QC and QC Gov Facebook pages for updates.',
    'source_url': 'https://quezoncity.gov.ph/program/start-up-qc-program/',
    'published_date': '2026-07-08T09:00:00',
    'tenant_id': 1,
  },
  {
    'title': 'Start-Up QC Student Competition: Up to P100,000 for '
        'Student Founders',
    'content':
        'The Quezon City Government, via the QC Local Economic Development '
        'and Investment Promotions Office, extends startup opportunities to '
        'students from schools and universities citywide. Participants pitch '
        'innovative business proposals that help the city\'s key sectors, '
        'such as agriculture, finance, education, health, information '
        'technology, culture, and arts.\n\n'
        'Each cohort ("Squad") receives training, mentorship, and networking '
        'activities facilitated by the local government. Prizes: First Place '
        'P100,000; Second Place P75,000; Third Place P50,000; Gold P35,000; '
        'Silver P25,000; Bronze P15,000.\n\n'
        'As of April 2026, Squad 1 had 27 awardees and Squad 2 had 29, with '
        'the Squad 3 competition now open. Watch the official Start-Up '
        'Facebook page and QC Gov FB page for announcements, or contact '
        'QC LEDIPO for more information.',
    'source_url':
        'https://quezoncity.gov.ph/program/start-up-student-competition/',
    'published_date': '2026-07-06T09:00:00',
    'tenant_id': 1,
  },
  {
    'title': 'No Woman Left Behind: Health, Education, and Livelihood for '
        'Female PDLs',
    'content':
        'Through the Quezon Gender and Development Council and the Office of '
        'the City Mayor, the No Woman Left Behind program improves welfare '
        'for female Persons Deprived of Liberty (PDLs) during and after '
        'detention.\n\n'
        'Healthcare: medical services including lab work, pregnancy tests, '
        'and vaccines — 19,376 medical interventions performed since 2021 '
        '(as of March 2026).\n\n'
        'Education: in partnership with Quezon City University, participants '
        'access basic and higher education and the Alternative Learning '
        'System; 353 PDLs have graduated from Elementary-SHS and 43 with a '
        'BS in Entrepreneurship.\n\n'
        'Livelihood: capital assistance, the Vote to Tote upcycling campaign, '
        'and the Cup of Joy coffee shop with barista training — 291 '
        'participants to date. After care: 162 released PDLs have received '
        'capital assistance for reintegration.\n\n'
        'For details, contact the QC GAD Council.',
    'source_url': 'https://quezoncity.gov.ph/program/no-woman-left-behind-2/',
    'published_date': '2026-07-04T09:00:00',
    'tenant_id': 1,
  },
];
