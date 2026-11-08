//
//  RealMenuSeed.swift
//  VIT-AP Mess Menu
//
//  The official VIT-AP mess menu for September 2026, transcribed from the
//  hostel's published Excel sheet. Bundled so the app is correct from first
//  launch; the admin's "Import" action in Settings pushes this same data
//  into Firestore so it can then be edited/updated for later months without
//  shipping a new build.
//

import Foundation

enum RealMenuSeed {
    /// One representative month's menu (no per-block variation captured
    /// yet). Used as the starting placeholder for *every* hostel block
    /// until that block's own operator enters their real menu.
    private static let templateEntries: [DayMenu] = [
        DayMenu(
            id: "regular_monday_a",
            plan: .regular,
            weekday: .monday,
            cycleWeek: .a,
            breakfast: ["Carrot Idly", "Bhature - 2 Pcs Big", "Groundnut Chutney, Sambar", "Chole Curry", "Brown Bread+Butter+Jam", "Sprouts (1 small cup)", "Tea/Coffee/Milk", "Egg Bhurji"],
            lunch: ["Beetroot & Cucumber Salad", "Chapathi", "White Rice", "Palak Dal", "Sambar", "Tomato Rice", "Pesara Punugulu Curry (Pakka Andhra Style)", "Drumstick Tomato Masala", "Rava Vadiyalu", "Butter Milk", "Sorakaya Perugu Chutney, Ghee + Podi", "Jilebi", "Ghee + Podi"],
            snacks: ["Dry Maggi", "Tomato Sauce", "Masala Tea/Coffee/Milk"],
            dinner: ["Onions & Lemon Salad", "Methi Roti", "White Rice", "Pesara Pappu", "Tomato Rasam", "Bhagara Rice", "Telangana Chicken Curry (Non-Veg)", "Achari Paneer (Veg)", "Ladies Finger Boiled Fry", "Thick Curd", "Mixed Fruit Salad", "Gongura Pickle", "Milk + Cofee Powder"]
        ),
        DayMenu(
            id: "regular_monday_b",
            plan: .regular,
            weekday: .monday,
            cycleWeek: .b,
            breakfast: ["Konaseema Pottikkalu (14) / Idly Upma (28)", "Poori - 3 Pcs Big", "Coconut Chutney", "Chole Curry", "White Bread+Butter+Jam", "Sprouts (1 small cup)", "Tea/Coffee/Milk", "Scrambled Egg"],
            lunch: ["Beetroot & Cucumber Salad", "Chapathi", "White Rice", "Palak Dal", "Sambar", "Tomato Rice", "Potato Fry (Andha Style)", "Drumstick Tomato Masala", "Rava Vadiyalu", "Butter Milk", "Sorakaya Perugu Chutney, Ghee + Podi", "Sweet Boondi", "Ghee + Podi"],
            snacks: ["Sweet Corn Masala", "Tomato/Mint Sauce", "Ginger Tea/Coffee/Milk"],
            dinner: ["Onions & Lemon Salad", "Methi Roti", "White Rice", "Pesara Pappu", "Tomato Rasam", "Bhagara Rice", "Chettinad Chicken Curry (Non-Veg)", "Paneer Pepper Fry(Veg)", "Bhindi Masala", "Thick Curd", "Mixed Fruit Salad", "Gongura Pickle", "Milk + Cofee Powder"]
        ),
        DayMenu(
            id: "regular_tuesday_a",
            plan: .regular,
            weekday: .tuesday,
            cycleWeek: .a,
            breakfast: ["Multi Grain Dosa (2 Pcs Thin)", "Pav Bhaji", "Coconut Chutney", "Mint Chutney", "White Bread+Butter+Jam", "Sprouts (1 small cup)", "Tea/Coffee/Milk", "Scrambled Egg"],
            lunch: ["Carrot & Cucumber Salad", "Roti", "White Rice", "Amaranthus Dal", "Beetroot Tomato Rasam", "Bisbele Bath", "Kakarakaya (Bitter Gourd) Fry", "Rajma Masala", "Potato Chips", "Dahi Vada", "Dosakaya Tomato Chutney", "Ghee + Podi"],
            snacks: ["Aloo Samosa 1 Big Pc", "Tomato Sauce", "Ginger Tea/Coffee/Milk"],
            dinner: ["Beetroot & Carrot Salad", "Pulka", "White Rice", "Dal Makhani", "Sambar", "Mushroom Biryani", "Snake Gourd Poriyal", "Aloo Mutter Curry", "Thick Curd", "Guava Fruit", "Tomato Pickle", "Milk + Cofee Powder"]
        ),
        DayMenu(
            id: "regular_tuesday_b",
            plan: .regular,
            weekday: .tuesday,
            cycleWeek: .b,
            breakfast: ["Onion Dosa - 2 Pcs Std Size", "Vada Pav", "Coconut Chutney", "Mint Chutney", "Brown Bread+Butter+Jam", "Sprouts (1 small cup)", "Tea/Coffee/Milk", "Boiled Egg"],
            lunch: ["Carrot & Cucumber Salad", "Roti", "White Rice", "Amaranthus Dal", "Beetroot Tomato Rasam", "Bisbele Bath", "Kakarakaya (Bitter Gourd) Fry", "Rajma Masala", "Potato Chips", "Dahi Vada", "Dosakaya Tomato Chutney", "Ghee + Podi"],
            snacks: ["Kachori 1 Big Pc", "Tomato Sauce", "Masala Tea/Coffee/Milk"],
            dinner: ["Beetroot & Carrot Salad", "Pulka", "White Rice", "Dal Makhani", "Sambar", "Mushroom Biryani", "Snake Gourd Poriyal", "Aloo Mutter Curry", "Thick Curd", "Guava Fruit", "Tomato Pickle", "Milk + Cofee Powder"]
        ),
        DayMenu(
            id: "regular_wednesday_a",
            plan: .regular,
            weekday: .wednesday,
            cycleWeek: .a,
            breakfast: ["Methu Vada (Big size 3pcs, if not 4pcs)", "Moong Dal Palak Tepla (Hand Made) 2 Pcs", "Sambar", "Tomato Chutney", "Brown Bread+Butter+Jam", "Sprouts (1 small cup)", "Tea/Coffee/Milk", "Boiled Egg"],
            lunch: ["Onions & Lemon Salad", "Palak Roti", "White Rice", "Gongura (Sorrel Leaves) Dal", "Sambar", "Vegetable Dum Pulav", "Masala Fish Fry / Andhra Chicken Fry", "Kaju Tomato Paneer Boiled Fry", "Black Chana Masala", "Trinagle Fryums", "Butter Milk", "Coriander + Tomato Chutney", "Gulab Jamun"],
            snacks: ["Corn Vada", "Onion Tomato Chutney", "Masala Tea/Coffee/Milk"],
            dinner: ["Beetroot & Carrot Salad", "Chapathi", "White Rice", "Tomato Dal", "Rasam", "Sooji Upma, Coconut Chutney", "Carrot Beans Poriyal", "Soya Chunks Masala", "Thick Curd", "Fruit Custard with Pine apple", "Lemon Pickle", "Milk + Cofee Powder"]
        ),
        DayMenu(
            id: "regular_wednesday_b",
            plan: .regular,
            weekday: .wednesday,
            cycleWeek: .b,
            breakfast: ["Onion Rava Bonda (Big size 3pcs, if not 4pcs)", "Cucumber Poha", "Sambar", "Coconut Chutney", "White Bread+Butter+Jam", "Sprouts (1 small cup)", "Tea/Coffee/Milk", "Masala Onion Omlet"],
            lunch: ["Onions & Lemon Salad", "Palak Roti", "White Rice", "Gongura (Sorrel Leaves) Dal", "Pachi Pulusu", "Special Rice", "Boiled Stir Fry Chicken Masala (Dry)", "Boiled Stir Fry Paneer Masala (Dry)", "Vegetable Jalfrezi", "Chips/Fryums/Papad", "Lemon Water + Sabja Seeds", "Fresh Vegetable Chutney", "Badusha"],
            snacks: ["Onion Soft Pakoda", "Tomato Chutney", "Ginger Tea/Coffee/Milk"],
            dinner: ["Beetroot & Carrot Salad", "Chapathi", "White Rice", "Tomato Dal", "Rasam", "Broken Wheat Rava Upma, Coconut Chutney", "Carrot Beans Poriyal", "Arbi Ka Gravy", "Thick Curd", "Fruit Custard with mixed fruits", "Lemon Pickle", "Milk + Cofee Powder"]
        ),
        DayMenu(
            id: "regular_thursday_a",
            plan: .regular,
            weekday: .thursday,
            cycleWeek: .a,
            breakfast: ["Poori (3 Pcs standard size)", "Lemon Sevai", "Aloo Mutter Curry", "Coconut Chutney", "White Bread+Butter+Jam", "Sprouts (1 small cup)", "Tea/Coffee/Milk", "Masala Onion Omlet"],
            lunch: ["Carrot & Cucumber Salad", "Pulka", "White Rice", "Ridge Gourd Dal", "Sambar", "Pudina Rice", "Guthi Vankaya Curry", "Cluster Beans Masala", "Finger Fryums", "Lemon Water + Sabja Seeds", "Potlakaya Perugu Chutney", "Ghee + Podi"],
            snacks: ["Poha Cutlet", "Mint Sauce", "Ginger Tea/Coffee/Milk"],
            dinner: ["Beetroot & Carrot Salad", "Roti", "White Rice", "Dal Maharani", "Beetroot Tomato Rasam", "Veg Manchuria, Noodles, Tomato Sauce", "Arbi Ka Gravy", "Rasam", "Thick Curd", "Banana", "Ginger Pickle", "Milk + Cofee Powder"]
        ),
        DayMenu(
            id: "regular_thursday_b",
            plan: .regular,
            weekday: .thursday,
            cycleWeek: .b,
            breakfast: ["Poori (3 pcs standard size)", "Tomato Suji Upma", "Aloo Basin Chutney", "Peanut Chutney", "Brown Bread+Butter+Jam", "Sprouts (1 small cup)", "Tea/Coffee/Milk", "Egg Bhurji (Non-Veg)"],
            lunch: ["Carrot & Cucumber Salad", "Pulka", "White Rice", "Ridge Gourd Dal", "Sambar", "Pudina Rice", "Guthi Vankaya Curry", "Kala Chana Masala", "Finger Fryums", "Lemon Water + Sabja Seeds", "Potlakaya Perugu Chutney", "Ghee + Podi"],
            snacks: ["Sambar Vada 2 Pcs", "Masala Tea/Coffee/Milk"],
            dinner: ["Beetroot & Carrot Salad", "Roti", "White Rice", "Dal Fry", "Beetroot Tomato Rasam", "Gobhi Manchuria, Noodles, Tomato Sauce", "Rajma Masala", "Rasam", "Thick Curd", "Banana", "Ginger Pickle", "Milk + Cofee Powder"]
        ),
        DayMenu(
            id: "regular_friday_a",
            plan: .regular,
            weekday: .friday,
            cycleWeek: .a,
            breakfast: ["Uggani + Mirchi Bajji", "Methi Roti or Methi Chapathi (Hand made) 2 Pcs", "Coconut Chutney", "Green Peas + Tomato Sabji", "Brown Bread+Butter+Jam", "Sprouts (1 small cup)", "Tea/Coffee/Milk", "Boiled Egg"],
            lunch: ["Beetroot & Cucumber Salad", "Chapathi", "White Rice", "Dal Tadka", "Rasam", "Jeera Rice", "Raw Banana Fry", "Aloo Gobhi Masala", "Papad", "Lassi", "Beerakaya Chutney", "Semiya Payasam"],
            snacks: ["Raw Banana Bhajji", "Coconut Coriander Chutney", "Masala Tea/Coffee/Milk"],
            dinner: ["Onions & Lemon Salad", "Lacha Paratha", "White Rice", "Pesara Pappu", "Sambar", "Dhaba Style Chicken Curry (Non-Veg)", "Paneer Butter Masala (Veg)", "Tomato Peas Capsicum Masala", "Thick Curd", "(Watermelon + Muskmelon + Papaya) Cut Fruit", "Mango Pickle", "Milk + Cofee Powder"]
        ),
        DayMenu(
            id: "regular_friday_b",
            plan: .regular,
            weekday: .friday,
            cycleWeek: .b,
            breakfast: ["Uggani + Mirchi Bajji", "Pudina Chapathi (Hand Made) 2 Pcs", "Dal Chutney", "Aloo Mutter Curry", "White Bread+Butter+Jam", "Sprouts (1 small cup)", "Tea/Coffee/Milk", "Boiled Egg"],
            lunch: ["Beetroot & Cucumber Salad", "Chapathi", "White Rice", "Dal Tadka", "Rasam", "Jeera Rice", "Raw Banana Fry", "Lobia Masala (Cowpeas in Onion Tomato Gravy)", "Papad", "Lassi", "Beerakaya Chutney", "Poornalu"],
            snacks: ["Vada Pav 2 Pcs", "Mint Sauce", "Ginger Tea/Coffee/Milk"],
            dinner: ["Onions & Lemon Salad", "Missi Roti", "White Rice", "Dal", "Sambar", "Kadai Chicken (Non-Veg)", "Kadai Paneer (Veg)", "Amritsari Chole", "Thick Curd", "(Watermelon + Muskmelon + Papaya) Cut Fruit", "Fresh Vegetable Chutney/Pickle", "Milk + Cofee Powder"]
        ),
        DayMenu(
            id: "regular_saturday_a",
            plan: .regular,
            weekday: .saturday,
            cycleWeek: .a,
            breakfast: ["Onion & Carrot Utappam", "Vegetable Poha", "Peanut Chutney", "Tomato Chutney", "White Bread+Butter+Jam", "Sprouts (1 small cup)", "Tea/Coffee/Milk", "Boiled Egg"],
            lunch: ["Carrot & Cucumber Salad", "Pulka", "White Rice", "Mudda Pappu", "Beetroot Tomato Rasam", "Pulihora (Tamarind Rice)", "Dondakaya Stir Fry", "Chole Soya Chunks Curry", "Papad", "Majiga Pulusu", "Avakaya (Mango Pickle)", "Ghee + Podi"],
            snacks: ["Punugulu 10 Pcs Std Size", "Groundnut/Coconut Chutney", "Ginger Tea/Coffee/Milk"],
            dinner: ["Beetroot & Carrot Salad", "Roti", "White Rice", "Mango Dal", "Bachali Kura Pulusu (Malabar Spinach)", "Set Dosa -2 Pcs, Coconut Chutney", "Cabbage Beans Poriyal", "Tomato Baingan Masala", "Thick Curd", "Muskmelon Cut Fruit", "Red Chilli Pickle", "Milk + Cofee Powder"]
        ),
        DayMenu(
            id: "regular_saturday_b",
            plan: .regular,
            weekday: .saturday,
            cycleWeek: .b,
            breakfast: ["Masala Ghee Roast Dosa 2 Pcs Std Size", "Vegetable Moon Dal Kitchidi", "Groundnut Chutney", "Sambar", "Brown Bread+Butter+Jam", "Sprouts (1 small cup)", "Tea/Coffee/Milk", "Scrambled Egg"],
            lunch: ["Carrot & Cucumber Salad", "Pulka", "White Rice", "Mudda Pappu", "Beetroot Tomato Rasam", "Pulihora (Tamarind Rice)", "Cauli Flower Fry", "Chole Soya Chunks Curry", "Papad", "Majiga Pulusu", "Avakaya (Mango Pickle)", "Ghee + Podi"],
            snacks: ["Mysore Bonda 2 Pcs Std Size", "Coconut Chutney", "Masala Tea/Coffee/Milk"],
            dinner: ["Beetroot & Carrot Salad", "Roti", "White Rice", "Mango Dal", "Bachali Kura Pulusu (Malabar Spinach)", "Podi Onion Dosa -2 Pcs, Dal Chutney", "Cabbage Beans Poriyal", "Tomato Baingan Masala", "Thick Curd", "Muskmelon Cut Fruit", "Red Chilli Pickle", "Milk + Cofee Powder"]
        ),
        DayMenu(
            id: "regular_sunday_a",
            plan: .regular,
            weekday: .sunday,
            cycleWeek: .a,
            breakfast: ["Shavige Bath", "Paneer Paratha - 2 Pcs Thin", "Coconut Chutney", "Thick Curd, Mango Pickle", "Brown Bread+Butter+Jam", "Sprouts (1 small cup)", "Tea/Coffee/Milk", "Egg Bhurji"],
            lunch: ["Beetroot & Cucumber Salad", "Chapathi", "White Rice", "Dal Fry", "Chicken Dum Biryani/Paneer Dum Biryani", "Chicken Thick Gravy / Hyderabadi Mirchi Ka Salan", "Onion Raitha", "Fryums", "Nannari Sharbath", "Fresh Gongura Chutney", "Vanilla Ice Cream (Not Frozen Dessert)"],
            snacks: ["Dahi Puri (8 Pcs)", "Onions", "Masala Tea/Coffee/Milk"],
            dinner: ["Beetroot & Carrot Salad", "Pulka", "White Rice", "Pesara Pappu", "Rasam", "Ragi Dosa, Tomato Chutney", "Dondakaya Fry", "Vegetable Kurma Gravy", "Thick Curd", "Papaya Cut Fruit", "Tomato Pickle", "Milk + Cofee Powder"]
        ),
        DayMenu(
            id: "regular_sunday_b",
            plan: .regular,
            weekday: .sunday,
            cycleWeek: .b,
            breakfast: ["Coconut Sevai", "Aloo Paratha (2 Pcs Thin)", "Onion Tomato Chutney", "Thick Curd, Mango Pickle", "White Bread+Butter+Jam", "Sprouts (1 small cup)", "Tea/Coffee/Milk", "Egg Bhurji"],
            lunch: ["Beetroot & Cucumber Salad", "Chapathi", "White Rice", "Dal Makhani", "Chicken Dum Biryani/Paneer Dum Biryani", "Chicken Thick Gravy / Hyderabadi Mirchi Ka Salan", "Onion Raitha", "Fryums", "Nannari Sharbath", "Fresh Gongura Chutney", "Kulfi (Not Frozen Dessert)"],
            snacks: ["Pani Puri (8 Pcs)", "Onions", "Ginger Tea/Coffee/Milk"],
            dinner: ["Beetroot & Carrot Salad", "Pulka", "White Rice", "Pesara Pappu", "Rasam", "Ragi Rava Upma, Coconut Chutney", "Dondakaya Fry", "Vegetable Kolhapuri", "Thick Curd", "Papaya Cut Fruit", "Tomato Pickle", "Milk + Cofee Powder"]
        ),
        DayMenu(
            id: "special_monday_a",
            plan: .special,
            weekday: .monday,
            cycleWeek: .a,
            breakfast: ["Carrot Idly", "Bhature - 2 Pcs Big", "Groundnut Chutney, Sambar", "Chole Curry", "White Bread+Butter+Jam", "Sprouts (1 small cup)", "Tea/Coffee/Milk", "Banana Milk Shake", "Cornflakes", "Egg Bhurji (Non-Veg)", "Paneer Bhurji (Veg)"],
            lunch: ["Beetroot & Cucumber Salad", "Chapathi", "White Rice", "Palak Dal", "Sambar", "Tomato Rice", "Pesara Punugulu Curry (Pakka Andhra Style)", "Drumstick Tomato Masala", "Rava Vadiyalu", "Butter Milk", "Sorakaya Perugu Chutney, Ghee + Podi", "Jilebi", "Ghee + Podi"],
            snacks: ["Dry Maggi", "Tomato Sauce", "Masala Tea/Coffee/Milk"],
            dinner: ["Onions & Lemon Salad", "Methi Butter Roti", "White Rice", "Pesara Pappu", "Tomato Rasam", "Bhagara Rice", "Telangana Chicken Curry (Non-Veg)", "Achari Paneer (Veg)", "Ladies Finger Boiled Fry", "Thick Curd", "Mixed Fruit Salad", "Gongura Pickle", "Milk + Cofee Powder", "Sweet Corn Soup"]
        ),
        DayMenu(
            id: "special_monday_b",
            plan: .special,
            weekday: .monday,
            cycleWeek: .b,
            breakfast: ["Konaseema Pottikkalu (14) / Idly Upma (28)", "Poori - 3 Pcs Big", "Coconut Chutney", "Chole Curry", "Brown Bread+Peanut Butter+Jam", "Sprouts (1 small cup)", "Tea/Coffee/Milk", "Cold Badam Milk", "Museli", "Scrambled Egg (Non-Veg)", "Paneer Bhurji (Veg)"],
            lunch: ["Beetroot & Cucumber Salad", "Chapathi", "White Rice", "Palak Dal", "Sambar", "Tomato Rice", "Potato Fry (Andha Style)", "Drumstick Tomato Masala", "Rava Vadiyalu", "Butter Milk", "Sorakaya Perugu Chutney, Ghee + Podi", "Sweet Boondi", "Ghee + Podi"],
            snacks: ["Sweet Corn Masala", "Tomato/Mint Sauce", "Ginger Tea/Coffee/Milk"],
            dinner: ["Onions & Lemon Salad", "Methi Roti", "White Rice", "Pesara Pappu", "Tomato Rasam", "Bhagara Rice", "Chettinad Chicken Curry (Non-Veg)", "Paneer Pepper Fry(Veg)", "Bhindi Masala", "Thick Curd", "Mixed Fruit Salad", "Gongura Pickle", "Milk + Cofee Powder", "Sweet Corn Soup"]
        ),
        DayMenu(
            id: "special_tuesday_a",
            plan: .special,
            weekday: .tuesday,
            cycleWeek: .a,
            breakfast: ["Multi Grain Dosa (2 Pcs Thin)", "Pav Bhaji", "Coconut Chutney", "Mint Chutney", "White Bread+Butter+Jam", "Sprouts (1 small cup)", "Tea/Coffee/Milk", "Pomegranate Fresh Juice", "Museli", "Scrambled Egg (Non-Veg)", "Boiled Soya Bean Salad (Veg)"],
            lunch: ["Carrot & Cucumber Salad", "Roti", "White Rice", "Amaranthus Dal", "Beetroot Tomato Rasam", "Bisbele Bath", "Kakarakaya (Bitter Gourd) Fry", "Rajma Masala", "Potato Chips", "Dahi Vada", "Dosakaya Tomato Chutney", "Rasamalai (1, 29), Kalakand (15)", "Ghee + Podi"],
            snacks: ["Aloo Samosa 1 Big Pc", "Tomato Sauce", "Ginger Tea/Coffee/Milk"],
            dinner: ["Beetroot & Carrot Salad", "Pulka", "White Rice", "Dal Makhani", "Sambar", "Mushroom Biryani", "Snake Gourd Poriyal", "Aloo Mutter Curry", "Thick Curd", "Guava Fruit", "Tomato Pickle", "Milk + Cofee Powder", "Brocolli Soup"]
        ),
        DayMenu(
            id: "special_tuesday_b",
            plan: .special,
            weekday: .tuesday,
            cycleWeek: .b,
            breakfast: ["Onion Dosa - 2 Pcs Std Size", "Vada Pav", "Coconut Chutney", "Mint Chutney", "Brown Bread+Peanut Butter+Jam", "Sprouts (1 small cup)", "Tea/Coffee/Milk", "Pomegranate Fresh Juice", "Chocos", "Boiled Egg (Non-Veg)", "Boiled Soya Chunk Salad (Veg)"],
            lunch: ["Carrot & Cucumber Salad", "Roti", "White Rice", "Amaranthus Dal", "Beetroot Tomato Rasam", "Bisbele Bath", "Kakarakaya (Bitter Gourd) Fry", "Rajma Masala", "Potato Chips", "Dahi Vada", "Dosakaya Tomato Chutney", "Puran Poli", "Ghee + Podi"],
            snacks: ["Kachori 1 Big Pc", "Tomato Sauce", "Masala Tea/Coffee/Milk"],
            dinner: ["Beetroot & Carrot Salad", "Pulka", "White Rice", "Dal Makhani", "Sambar", "Mushroom Biryani", "Snake Gourd Poriyal", "Aloo Mutter Curry", "Thick Curd", "Guava Fruit", "Tomato Pickle", "Milk + Cofee Powder", "Brocolli Soup"]
        ),
        DayMenu(
            id: "special_wednesday_a",
            plan: .special,
            weekday: .wednesday,
            cycleWeek: .a,
            breakfast: ["Methu Vada (Big size 3pcs, if not 4pcs)", "Moong Dal Palak Tepla (Hand Made) 2 Pcs", "Sambar", "Tomato Chutney", "Brown Bread+Peanut Butter+Jam", "Sprouts (1 small cup)", "Tea/Coffee/Milk", "Muskmelon Fresh Juice", "Chocos", "Boiled Egg (Non-Veg)", "Boiled Chick Peas Salad (Veg)"],
            lunch: ["Onions & Lemon Salad", "Palak Roti", "White Rice", "Gongura (Sorrel Leaves) Dal", "Sambar", "Vegetable Dum Pulav", "Masala Fish Fry / Andhra Chicken Fry", "Kaju Tomato Paneer Boiled Fry", "Black Chana Masala", "Trinagle Fryums", "Butter Milk", "Coriander + Tomato Chutney", "Gulab Jamun"],
            snacks: ["Corn Vada", "Onion Tomato Chutney", "Masala Tea/Coffee/Milk"],
            dinner: ["Beetroot & Carrot Salad", "Chapathi", "White Rice", "Tomato Dal", "Rasam", "Sooji Upma, Coconut Chutney", "Carrot Beans Poriyal", "Soya Chunks Masala", "Thick Curd", "Fruit Custard with Pine apple", "Lemon Pickle", "Milk + Cofee Powder", "Tomato Soup with Roasted Bread"]
        ),
        DayMenu(
            id: "special_wednesday_b",
            plan: .special,
            weekday: .wednesday,
            cycleWeek: .b,
            breakfast: ["Onion Rava Bonda (Big size 3pcs, if not 4pcs)", "Cucumber Poha", "Sambar", "Coconut Chutney", "White Bread+Butter+Jam", "Sprouts (1 small cup)", "Tea/Coffee/Milk", "Papaya Fresh Juice", "Cornflakes", "Masala Onion Omlet  (Non-Veg)", "Greek Yogurt Salad (Veg)"],
            lunch: ["Onions & Lemon Salad", "Palak Roti", "White Rice", "Gongura (Sorrel Leaves) Dal", "Pachi Pulusu", "Special Rice", "Boiled Stir Fry Chicken Masala (Dry)", "Boiled Stir Fry Paneer Masala (Dry)", "Vegetable Jalfrezi", "Chips/Fryums/Papad", "Lemon Water + Sabja Seeds", "Fresh Vegetable Chutney", "Badusha"],
            snacks: ["Onion Soft Pakoda", "Tomato Chutney", "Ginger Tea/Coffee/Milk"],
            dinner: ["Beetroot & Carrot Salad", "Chapathi", "White Rice", "Tomato Dal", "Rasam", "Broken Wheat Rava Upma, Coconut Chutney", "Carrot Beans Poriyal", "Arbi Ka Gravy", "Thick Curd", "Fruit Custard with mixed fruits", "Lemon Pickle", "Milk + Cofee Powder", "Tomato Soup with Roasted Bread"]
        ),
        DayMenu(
            id: "special_thursday_a",
            plan: .special,
            weekday: .thursday,
            cycleWeek: .a,
            breakfast: ["Poori (3 Pcs standard size)", "Lemon Sevai", "Aloo Mutter Curry", "Coconut Chutney", "White Bread+Butter+Jam", "Sprouts (1 small cup)", "Tea/Coffee/Milk", "Grapes Fresh Juice", "Cornflakes", "Masala Onion Omlet (Non-Veg)", "Boiled Paneer Salad (Veg)"],
            lunch: ["Carrot & Cucumber Salad", "Pulka", "White Rice", "Ridge Gourd Dal", "Sambar", "Pudina Rice", "Guthi Vankaya Curry", "Cluster Beans Masala", "Finger Fryums", "Lemon Water + Sabja Seeds", "Potlakaya Perugu Chutney", "Shahi Ki Tukda", "Ghee + Podi"],
            snacks: ["Poha Cutlet", "Mint Sauce", "Ginger Tea/Coffee/Milk"],
            dinner: ["Beetroot & Carrot Salad", "Roti", "White Rice", "Dal Maharani", "Beetroot Tomato Rasam", "Veg Manchuria, Noodles, Tomato Sauce", "Chicken 65/Andhra Fish Fry (NV), Paneer 65 (Veg)", "Arbi Ka Gravy", "Thick Curd", "Banana", "Ginger Pickle", "Milk + Cofee Powder", "Creamy Mushroom Soup"]
        ),
        DayMenu(
            id: "special_thursday_b",
            plan: .special,
            weekday: .thursday,
            cycleWeek: .b,
            breakfast: ["Poori (3 pcs standard size)", "Tomato Suji Upma", "Aloo Basin Chutney", "Peanut Chutney", "Brown Bread+Peanut Butter+Jam", "Sprouts (1 small cup)", "Tea/Coffee/Milk", "Grapes Fresh Juice", "Museli", "Egg Bhurji (Non-Veg)", "Boiled Paneer Salad (Veg)"],
            lunch: ["Carrot & Cucumber Salad", "Pulka", "White Rice", "Ridge Gourd Dal", "Sambar", "Pudina Rice", "Guthi Vankaya Curry", "Kala Chana Masala", "Finger Fryums", "Lemon Water + Sabja Seeds", "Potlakaya Perugu Chutney", "Mothichoor Laddu", "Ghee + Podi"],
            snacks: ["Sambar Vada", "Masala Tea/Coffee/Milk"],
            dinner: ["Beetroot & Carrot Salad", "Roti", "White Rice", "Dal Fry", "Beetroot Tomato Rasam", "Gobhi Manchuria, Noodles, Tomato Sauce", "Chilli Chicken/Malabar Fish Fry (NV), Chilli Paneer (Veg)", "Rajma Masala", "Thick Curd", "Banana", "Ginger Pickle", "Milk + Cofee Powder", "Creamy Mushroom Soup"]
        ),
        DayMenu(
            id: "special_friday_a",
            plan: .special,
            weekday: .friday,
            cycleWeek: .a,
            breakfast: ["Uggani + Mirchi Bajji", "Methi Roti or Methi Chapathi (Hand made) 2 Pcs", "Coconut Chutney", "Green Peas + Tomato Sabji", "Brown Bread+Peanut Butter+Jam", "Sprouts (1 small cup)", "Tea/Coffee/Milk", "Pineapple Fresh Juice", "Museli", "Boiled Egg (Non-Veg)", "Boiled Peanut Sundal (Veg)"],
            lunch: ["Beetroot & Cucumber Salad", "Chapathi", "White Rice", "Dal Tadka", "Rasam", "Jeera Rice", "Raw Banana Fry", "Aloo Gobhi Masala", "Papad", "Lassi", "Beerakaya Chutney", "Semiya Payasam"],
            snacks: ["Raw Banana Bhajji", "Coconut Coriander Chutney", "Masala Tea/Coffee/Milk"],
            dinner: ["Onions & Lemon Salad", "Lacha Paratha", "White Rice", "Pesara Pappu", "Sambar", "Dhaba Style Chicken Curry (Non-Veg)", "Paneer Butter Masala (Veg)", "Tomato Peas Capsicum Masala", "Thick Curd", "(Watermelon + Muskmelon + Papaya) Cut Fruit", "Mango Pickle", "Milk + Cofee Powder", "Mix Veg Raagi Soup"]
        ),
        DayMenu(
            id: "special_friday_b",
            plan: .special,
            weekday: .friday,
            cycleWeek: .b,
            breakfast: ["Uggani + Mirchi Bajji", "Pudina Chapathi (Hand Made) 2 Pcs", "Dal Chutney", "Aloo Mutter Curry", "White Bread+Butter+Jam", "Sprouts (1 small cup)", "Tea/Coffee/Milk", "Pineapple Fresh Juice", "Chocos", "Boiled Egg (Non-Veg)", "Boiled Chick Peas Salad (Veg)"],
            lunch: ["Beetroot & Cucumber Salad", "Chapathi", "White Rice", "Dal Tadka", "Rasam", "Jeera Rice", "Raw Banana Fry", "Lobia Masala (Cowpeas in Onion Tomato Gravy)", "Papad", "Lassi", "Beerakaya Chutney", "Poornalu"],
            snacks: ["Vada Pav 2 Pcs", "Mint Sauce", "Ginger Tea/Coffee/Milk"],
            dinner: ["Onions & Lemon Salad", "Butter Naan", "White Rice", "Dal", "Sambar", "Kadai Chicken (Non-Veg)", "Kadai Paneer (Veg)", "Amritsari Chole", "Thick Curd", "(Watermelon + Muskmelon + Papaya) Cut Fruit", "Fresh Vegetable Chutney/Pickle", "Milk + Cofee Powder", "Mix Veg Raagi Soup"]
        ),
        DayMenu(
            id: "special_saturday_a",
            plan: .special,
            weekday: .saturday,
            cycleWeek: .a,
            breakfast: ["Onion & Carrot Utappam", "Vegetable Poha", "Peanut Chutney", "Tomato Chutney", "White Bread+Butter+Jam", "Sprouts (1 small cup)", "Tea/Coffee/Milk", "Guava Fresh Juice", "Chocos", "Boiled Egg (Non-Veg)", "Sweet Potato Salad (Veg)"],
            lunch: ["Carrot & Cucumber Salad", "Pulka", "White Rice", "Mudda Pappu", "Beetroot Tomato Rasam", "Pulihora (Tamarind Rice)", "Dondakaya Stir Fry", "Chole Soya Chunks Curry", "Papad", "Majiga Pulusu", "Avakaya (Mango Pickle)", "Carrot Halwa", "Ghee + Podi"],
            snacks: ["Punugulu 10 Pcs Std Size", "Groundnut/Coconut Chutney", "Ginger Tea/Coffee/Milk"],
            dinner: ["Beetroot & Carrot Salad", "Roti", "White Rice", "Mango Dal", "Bachali Kura Pulusu (Malabar Spinach)", "Set Dosa -2 Pcs, Coconut Chutney", "Cabbage Beans Poriyal", "Tomato Baingan Masala", "Thick Curd", "Muskmelon Cut Fruit", "Red Chilli Pickle", "Milk + Cofee Powder", "Red Lentil Soup"]
        ),
        DayMenu(
            id: "special_saturday_b",
            plan: .special,
            weekday: .saturday,
            cycleWeek: .b,
            breakfast: ["Masala Ghee Roast Dosa", "Vegetable Moon Dal Kitchidi", "Groundnut Chutney", "Sambar", "Brown Bread+Peanut Butter+Jam", "Sprouts (1 small cup)", "Tea/Coffee/Milk", "Orange Fresh Juice", "Cornflakes", "Scrambled Egg (Non-Veg)", "Boiled Peanut Sundal (Veg)"],
            lunch: ["Carrot & Cucumber Salad", "Pulka", "White Rice", "Mudda Pappu", "Beetroot Tomato Rasam", "Pulihora (Tamarind Rice)", "Cauli Flower Fry", "Chole Soya Chunks Curry", "Papad", "Majiga Pulusu", "Avakaya (Mango Pickle)", "Chocolate Cake (Egg Less)", "Ghee + Podi"],
            snacks: ["Mysore Bonda 2 Pcs Std Size", "Coconut Chutney", "Masala Tea/Coffee/Milk"],
            dinner: ["Beetroot & Carrot Salad", "Roti", "White Rice", "Mango Dal", "Bachali Kura Pulusu (Malabar Spinach)", "Podi Onion Dosa -2 Pcs, Dal Chutney", "Cabbage Beans Poriyal", "Tomato Baingan Masala", "Thick Curd", "Muskmelon Cut Fruit", "Red Chilli Pickle", "Milk + Cofee Powder", "Veg Manchow Soup"]
        ),
        DayMenu(
            id: "special_sunday_a",
            plan: .special,
            weekday: .sunday,
            cycleWeek: .a,
            breakfast: ["Shavige Bath", "Paneer Paratha - 2 Pcs Thin", "Coconut Chutney", "Thick Curd, Mango Pickle", "Brown Bread+Peanut Butter+Jam", "Sprouts (1 small cup)", "Tea/Coffee/Milk", "Apple + Pomegranate Fresh Juice", "Cornflakes", "Egg Bhurji (Non-Veg)", "Raagi Malt (Veg)"],
            lunch: ["Beetroot & Cucumber Salad", "Chapathi", "White Rice", "Dal Fry", "Chicken Dum Biryani/Paneer Dum Biryani", "Chicken Thick Gravy / Hyderabadi Mirchi Ka Salan", "Onion Raitha", "Fryums", "Nannari Sharbath", "Fresh Gongura Chutney", "Vanilla Ice Cream (Not Frozen Dessert)", "Gulab Jamun"],
            snacks: ["Dahi Puri (8 Pcs)", "Onions", "Masala Tea/Coffee/Milk"],
            dinner: ["Beetroot & Carrot Salad", "Pulka", "White Rice", "Pesara Pappu", "Rasam", "Ragi Dosa, Tomato Chutney", "Dondakaya Fry", "Vegetable Kurma Gravy", "Thick Curd", "Papaya Cut Fruit", "Tomato Pickle", "Milk + Cofee Powder", "Lemon Coriander Soup"]
        ),
        DayMenu(
            id: "special_sunday_b",
            plan: .special,
            weekday: .sunday,
            cycleWeek: .b,
            breakfast: ["Coconut Sevai", "Aloo Paratha (2 Pcs Thin)", "Onion Tomato Chutney", "Thick Curd, Mango Pickle", "White Bread+Butter+Jam", "Sprouts (1 small cup)", "Tea/Coffee/Milk", "Apple + Pomegranate Juice", "Museli", "Egg Bhurji (Non-Veg)", "Ragi Malt (Veg)"],
            lunch: ["Beetroot & Cucumber Salad", "Chapathi", "White Rice", "Dal Makhani", "Chicken Dum Biryani/Paneer Dum Biryani", "Chicken Thick Gravy / Hyderabadi Mirchi Ka Salan", "Onion Raitha", "Fryums", "Nannari Sharbath", "Fresh Gongura Chutney", "Kulfi (Not Frozen Dessert)", "Gulab Jamun"],
            snacks: ["Pani Puri (8 Pcs)", "Onions", "Ginger Tea/Coffee/Milk"],
            dinner: ["Beetroot & Carrot Salad", "Pulka", "White Rice", "Pesara Pappu", "Rasam", "Ragi Rava Upma, Coconut Chutney", "Dondakaya Fry", "Vegetable Kolhapuri", "Thick Curd", "Papaya Cut Fruit", "Tomato Pickle", "Milk + Cofee Powder", "Lemon Coriander Soup"]
        ),
    ]

    /// `templateEntries` re-stamped with every hostel block's own id/block
    /// field — 11 blocks x 28 template entries.
    static var all: [DayMenu] {
        HostelBlock.all.flatMap { block in
            templateEntries.map { entry -> DayMenu in
                var copy = entry
                copy.block = block
                copy.id = DayMenu.docId(block: block, plan: copy.plan, weekday: copy.weekday, cycleWeek: copy.cycleWeek)
                return copy
            }
        }
    }

    static func bundledEntries() -> [String: DayMenu] {
        Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
    }
}
