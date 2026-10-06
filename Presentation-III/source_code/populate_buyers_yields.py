import sys
import datetime
import random
from backend.db import get_connection

def populate_buyers_and_yields():
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            # 1. Check existing buyer count
            cur.execute("SELECT COUNT(*), MAX(buyer_id) FROM buyer;")
            b_cnt, max_b_id = cur.fetchone().values()
            print(f"Initial Buyers: {b_cnt}, Max ID: {max_b_id}")

            new_buyers = [
                ("Baskin Robbins India Dairy", "9100000051", "Nariman Point, Mumbai"),
                ("Haldiram's Milk Procurement Hub", "9100000052", "MIDC Butibori, Nagpur"),
                ("Bikanervala Sweets Dairy Division", "9100000053", "Connaught Place, New Delhi"),
                ("Modern Food Enterprises", "9100000054", "Cyber City, Gurugram"),
                ("Godrej Jersey Processing Plant", "9100000055", "Nacharam Industrial Area, Hyderabad"),
                ("Gyan Dairy (CP Milk & Food)", "9100000056", "Kursi Road, Lucknow"),
                ("Prabhat Dairy Limited", "9100000057", "Shrirampur, Ahmednagar"),
                ("Sanchi Dairy Federation (MPCDF)", "9100000058", "Habibganj, Bhopal"),
                ("Medha Dairy (Jharkhand Co-op)", "9100000059", "Hotwar, Ranchi"),
                ("Oomfed Dairy Federation", "9100000060", "Saheed Nagar, Bhubaneswar"),
                ("Surabhi Milk Products", "9100000061", "Whitefield, Bengaluru"),
                ("Keventers Dairy Outlets", "9100000062", "Saket District Centre, New Delhi"),
                ("Mother Dairy Kolkata Processing Unit", "9100000063", "Dankuni, Kolkata"),
                ("Country Delight Direct Farm Supply", "9100000064", "Sector 62, Noida"),
                ("Akshayakalpa Organic Dairy", "9100000065", "Tiptur Farm Reserve, Karnataka"),
                ("Pride of Cows (Bhagirathi Dairies)", "9100000066", "Manchar Valley, Pune"),
                ("Sid's Farm Direct Milk Harvest", "9100000067", "Shabad, Ranga Reddy, Telangana"),
                ("Namaste India Foods", "9100000068", "Panki Industrial Estate, Kanpur"),
                ("Warana Milk Cooperative Union", "9100000069", "Warananagar, Kolhapur"),
                ("Sangam Dairy (Guntur Milk Union)", "9100000070", "Vadlamudi, Guntur"),
                ("Visakha Dairy Union (Vimul)", "9100000071", "Akkireddypalem, Visakhapatnam"),
                ("Krishna Milk Union (Vijaya Dairy)", "9100000072", "Milk Factory, Vijayawada"),
                ("Panchamrit Milk Union", "9100000073", "Maksi Road, Ujjain"),
                ("Mahanand Dairy Federation", "9100000074", "Aarey Milk Colony, Mumbai"),
                ("Rajkot District Co-op Milk Union", "9100000075", "Bhavnagar Road, Rajkot"),
                ("Banas Dairy (Palanpur Union)", "9100000076", "Palanpur Highway, Banaskantha"),
                ("Sabar Dairy (Himmatnagar Union)", "9100000077", "Subhadranagar, Himmatnagar"),
                ("Sumul Dairy (Surat Milk Union)", "9100000078", "Surat Railway Station Road, Surat"),
                ("Dudhsagar Dairy (Mehsana Union)", "9100000079", "Highway Road, Mehsana"),
                ("Baroda District Co-op Milk Union", "9100000080", "Makarpura, Vadodara"),
                ("Panchmahal District Co-op (Panchamrut)", "9100000081", "Godhra, Gujarat"),
                ("Valsad District Milk Producers (Vasudhara)", "9100000082", "Alipur, Navsari"),
                ("Kaira District Milk Producers (Amul Anand)", "9100000083", "Amul Dairy Road, Anand"),
                ("Verka Milk Plant Mohali", "9100000084", "Phase 6 Industrial Area, Mohali"),
                ("Vita Milk Cooperative (Haryana Dairy)", "9100000085", "Sector 2, Panchkula"),
                ("Saras Dairy Federation (RCDF)", "9100000086", "JLN Marg, Jaipur"),
                ("Sudha Milk Federation (COMFED)", "9100000087", "Patliputra Industrial Estate, Patna"),
                ("Gokul Milk Union (Kolhapur Co-op)", "9100000088", "Tarabai Park, Kolhapur"),
                ("Chitale Bandhu Dairy Products", "9100000089", "Bhilawadi, Sangli"),
                ("Katraj Dairy (Pune District Co-op)", "9100000090", "Katraj Ghat Road, Pune"),
                ("Dynamix Dairies Baramati Plant", "9100000091", "MIDC Baramati, Pune"),
                ("Schreiber Dynamix Dairies Fazilka", "9100000092", "Fazilka Food Park, Punjab"),
                ("Danone India Nutrition Supply", "9100000093", "DLF Cyber City, Gurugram"),
                ("Nestle India Moga Processing Facility", "9100000094", "GT Road, Moga, Punjab"),
                ("Britannia Industries Dairy Division", "9100000095", "Bidadi Industrial Area, Bengaluru"),
                ("Parag Milk Foods (Gowardhan Brand)", "9100000096", "Manchar, Ambegaon, Pune"),
                ("Creamline Dairy (Godrej Consumer)", "9100000097", "Cherlapally, Hyderabad"),
                ("Hatsun Agro Product (Arokya)", "9100000098", "OMR, Karapakkam, Chennai"),
                ("Aavin Central Dairy Madhavaram", "9100000099", "Madhavaram Milk Colony, Chennai"),
                ("Milky Mist Mega Dairy Park", "9100000100", "Perundurai, Erode, Tamil Nadu")
            ]

            added_buyers = 0
            for name, contact, addr in new_buyers:
                # Check if name already exists
                cur.execute("SELECT buyer_id FROM buyer WHERE buyer_name = %s;", (name,))
                if not cur.fetchone():
                    cur.execute("INSERT INTO buyer (buyer_name, contact, address) VALUES (%s, %s, %s);", (name, contact, addr))
                    added_buyers += 1
            
            print(f"Added {added_buyers} new commercial buyers.")

            # 2. Check existing milking sessions & yields
            cur.execute("SELECT COUNT(*) AS total_sess, MAX(session_id) AS max_sess FROM milking_session;")
            sess_stats = cur.fetchone()
            print(f"Existing Milking Sessions: {sess_stats['total_sess']}, Max Session ID: {sess_stats['max_sess']}")

            # Fetch active female cattle
            cur.execute("SELECT animal_id, animal_tag FROM animal WHERE gender='Female' AND status='Active' ORDER BY animal_id;")
            cows = cur.fetchall()
            print(f"Available active dairy cows: {len(cows)}")

            # Generate 50 fresh harvested milk sessions & yields
            start_date = datetime.date(2026, 7, 1)
            added_lots = 0
            
            for i in range(50):
                cow = cows[i % len(cows)]
                cow_id = cow["animal_id"]
                # Spread dates across July to October 2026
                day_offset = (i * 2) % 95
                sess_date = start_date + datetime.timedelta(days=day_offset)
                shift = "Morning" if (i % 2 == 0) else "Evening"
                sess_time = "06:15:00" if shift == "Morning" else "17:45:00"
                
                # Check if session tuple already exists
                cur.execute("""
                    SELECT session_id FROM milking_session 
                    WHERE animal_id = %s AND session_date = %s AND session_time = %s;
                """, (cow_id, sess_date, sess_time))
                
                existing = cur.fetchone()
                if not existing:
                    # Insert session
                    cur.execute("""
                        INSERT INTO milking_session (animal_id, session_date, session_time, session_type)
                        VALUES (%s, %s, %s, %s);
                    """, (cow_id, sess_date, sess_time, shift))
                    sess_id = cur.lastrowid

                    # Realistic yield: 14.5 to 28.0 litres
                    litres = round(14.0 + (i * 0.28) % 14.0, 2)
                    cur.execute("""
                        INSERT INTO milk_yield (session_id, quantity_litres)
                        VALUES (%s, %s);
                    """, (sess_id, litres))
                    added_lots += 1

            conn.commit()
            print(f"Successfully added {added_lots} fresh harvested milk lots (un-sold, ready in warehouse storage)!")

            # 3. Final verification
            cur.execute("SELECT COUNT(*) AS cnt FROM buyer;")
            final_buyers = cur.fetchone()["cnt"]

            cur.execute("SELECT COUNT(*) AS cnt FROM milk_yield;")
            final_yields = cur.fetchone()["cnt"]

            cur.execute("""
                SELECT COUNT(*) AS cnt FROM milk_yield my 
                WHERE my.yield_id NOT IN (SELECT COALESCE(si.yield_id, 0) FROM sale_item si);
            """)
            available_yields = cur.fetchone()["cnt"]

            print(f"Final Totals in MySQL:")
            print(f" - Buyers: {final_buyers}")
            print(f" - Total Milk Yield Lots: {final_yields}")
            print(f" - Available (Un-sold) Lots for Sale: {available_yields}")

    finally:
        conn.close()

if __name__ == "__main__":
    populate_buyers_and_yields()
