class Recommendation {
  final String dhatu;
  final String condition;          // "Vriddhi" | "Kshaya"
  final String pathyaAahar;        // Recommended diet (EN)
  final String pathyaAaharHi;      // Recommended diet (HI)
  final String apathyaAahar;       // Diet to avoid (EN)
  final String apathyaAaharHi;     // Diet to avoid (HI)
  final String pathyaVihara;       // Recommended lifestyle (EN)
  final String pathyaViharaHi;     // Recommended lifestyle (HI)
  final String apathyaVihara;      // Lifestyle to avoid (EN)
  final String apathyaViharaHi;    // Lifestyle to avoid (HI)
  final String aushadha;           // Ayurvedic medicine (EN)
  final String aushadhaHi;         // Ayurvedic medicine (HI)

  const Recommendation({
    required this.dhatu,
    required this.condition,
    required this.pathyaAahar,
    required this.pathyaAaharHi,
    required this.apathyaAahar,
    required this.apathyaAaharHi,
    required this.pathyaVihara,
    required this.pathyaViharaHi,
    required this.apathyaVihara,
    required this.apathyaViharaHi,
    required this.aushadha,
    required this.aushadhaHi,
  });
}

class RecommendationsData {
  static const List<Recommendation> recommendationTable = [
    // Rasa Vriddhi
    Recommendation(
      dhatu: 'Rasa',
      condition: 'Vriddhi',
      pathyaAahar: 'Bitter and astringent foods, ginger tea, warm cooked barley',
      pathyaAaharHi: 'कड़वे और कसैले भोजन, अदरक की चाय, गर्म पका हुआ जौ',
      apathyaAahar: 'Sweet, cold, heavy foods, fresh curd, ice creams, heavy dairy products',
      apathyaAaharHi: 'मीठे, ठंडे, भारी भोजन, ताजा दही, आइसक्रीम, भारी डेयरी उत्पाद',
      pathyaVihara: 'Regular physical exercise, warm water baths, active lifestyle',
      pathyaViharaHi: 'नियमित शारीरिक व्यायाम, गर्म पानी से स्नान, सक्रिय जीवनशैली',
      pathyaVihara: 'Sleeping during the day, lazy sedentary lifestyle',
      pathyaViharaHi: 'दिन में सोना, निष्क्रिय जीवनशैली',
      aushadha: 'Trikatu Churna, Pippali, Haritaki',
      aushadhaHi: 'त्रिकटु चूर्ण, पिप्पली, हरीतकी',
    ),
    // Rasa Kshaya
    Recommendation(
      dhatu: 'Rasa',
      condition: 'Kshaya',
      pathyaAahar: 'Warm, moist, sweet, sour, salty foods, warm milk, fresh fruit juices, coconut water',
      pathyaAaharHi: 'गर्म, नम, मीठे, खट्टे, नमकीन भोजन, गर्म दूध, ताजे फलों का रस, नारियल पानी',
      apathyaAahar: 'Dry, cold, bitter, astringent foods, long hours of fasting',
      apathyaAaharHi: 'सूखे, ठंडे, कड़वे, कसैले भोजन, लंबे समय तक उपवास',
      pathyaVihara: 'Gentle walks, oil massage (Abhyanga), adequate rest, stress relief',
      pathyaViharaHi: 'हल्की सैर, तेल मालिश (अभ्यंग), पर्याप्त विश्राम, तनाव से राहत',
      pathyaVihara: 'Excessive physical activity, staying up late at night',
      pathyaViharaHi: 'अत्यधिक शारीरिक गतिविधि, देर रात तक जागना',
      aushadha: 'Shatavari, Drakshasava, Ashwagandha Ghrita',
      aushadhaHi: 'शतावरी, द्राक्षासव, अश्वगंधा घृत',
    ),

    // Rakta Vriddhi
    Recommendation(
      dhatu: 'Rakta',
      condition: 'Vriddhi',
      pathyaAahar: 'Cooling foods, sweet, bitter, astringent tastes, pomegranate, green leafy vegetables, cucumber',
      pathyaAaharHi: 'ठंडी प्रकृति के भोजन, मीठे, कड़वे, कसैले स्वाद, अनार, हरी पत्तेदार सब्जियां, खीरा',
      apathyaAahar: 'Spicy, sour, salty, hot, fermented foods, vinegar, pickles, heavy alcohol',
      apathyaAaharHi: 'तीखे, खट्टे, नमकीन, गर्म, किण्वित (fermented) भोजन, सिरका, अचार, शराब',
      pathyaVihara: 'Moderate exercise in cool environments, meditation, walking in moonlight',
      pathyaViharaHi: 'ठंडे वातावरण में मध्यम व्यायाम, ध्यान, चांदनी में टहलना',
      pathyaVihara: 'Direct sun exposure, working near fire or heat, heavy anger',
      pathyaViharaHi: 'सीधे धूप में रहना, आग या गर्मी के पास काम करना, अत्यधिक क्रोध',
      aushadha: 'Kaishore Guggulu, Neem, Manjistha Churna',
      aushadhaHi: 'कैशोर गुग्गुलु, नीम, मंजिष्ठा चूर्ण',
    ),
    // Rakta Kshaya
    Recommendation(
      dhatu: 'Rakta',
      condition: 'Kshaya',
      pathyaAahar: 'Iron-rich foods, pomegranate, beetroot, spinach, red meat soup, milk with cow ghee',
      pathyaAaharHi: 'आयरन से भरपूर भोजन, अनार, चुकंदर, पालक, लाल मांस का सूप, गाय के घी के साथ दूध',
      apathyaAahar: 'Extremely dry, light, bitter, pungent foods, sour drinks',
      apathyaAaharHi: 'अत्यधिक सूखे, हल्के, कड़वे, तीखे भोजन, खट्टे पेय',
      pathyaVihara: 'Good hydration, moderate rest, mild sun baths in early morning',
      pathyaViharaHi: 'पर्याप्त जलायोजन (hydration), मध्यम विश्राम, सुबह की हल्की धूप',
      pathyaVihara: 'Excessive sweating, heavy exercises, frequent blood donation',
      pathyaViharaHi: 'अत्यधिक पसीना बहाना, भारी व्यायाम, बार-बार रक्तदान',
      aushadha: 'Lohasava, Punarnavadi Mandoor, Dhatri Lauha',
      aushadhaHi: 'लोहासव, पुनर्नवादि मंडूर, धात्री लौह',
    ),

    // Mamsa Vriddhi
    Recommendation(
      dhatu: 'Mamsa',
      condition: 'Vriddhi',
      pathyaAahar: 'Barley, millets, honey, light vegetarian diet, bitter vegetables, steamed lentils',
      pathyaAaharHi: 'जौ, बाजरा, शहद, हल्का शाकाहारी भोजन, कड़वी सब्जियां, उबली हुई दालें',
      apathyaAahar: 'Heavy meat, oily foods, excess sweets, deep fried foods, cheese and heavy dairy',
      apathyaAaharHi: 'भारी मांस, तैलीय भोजन, अत्यधिक मीठा, गहरे तले हुए भोजन, पनीर और भारी डेयरी',
      pathyaVihara: 'Vigorous exercise, dry massage (Udvartana), active physical routine',
      pathyaViharaHi: 'जोरदार व्यायाम, सूखा उबटन (उद्वर्तन), सक्रिय शारीरिक दिनचर्या',
      pathyaVihara: 'Daytime sleeping, lazy sedentary lifestyle, sitting for long hours',
      pathyaViharaHi: 'दिन में सोना, निष्क्रिय जीवनशैली, लंबे समय तक बैठना',
      aushadha: 'Kanchanar Guggulu, Triphala Churna',
      aushadhaHi: 'कांचनार गुग्गुलु, त्रिफला चूर्ण',
    ),
    // Mamsa Kshaya
    Recommendation(
      dhatu: 'Mamsa',
      condition: 'Kshaya',
      pathyaAahar: 'Protein-rich diet, black gram (Urad dal), meat soup, milk, ghee, nuts, wheat, rice',
      pathyaAaharHi: 'प्रोटीन युक्त भोजन, उड़द की दाल, मांस का सूप, दूध, घी, नट्स, गेहूं, चावल',
      apathyaAahar: 'Dry, light, spicy, bitter, astringent foods, prolonged fasting',
      apathyaAaharHi: 'सूखे, हल्के, तीखे, कड़वे, कसैले भोजन, लंबे समय तक उपवास',
      pathyaVihara: 'Strength training, body oil massage (Abhyanga), sufficient rest and sleep',
      pathyaViharaHi: 'शक्ति प्रशिक्षण (strength training), तेल मालिश, पर्याप्त विश्राम और नींद',
      pathyaVihara: 'Heavy cardio, fasting, sleeplessness, excess physical labor',
      pathyaViharaHi: 'भारी कार्डियो व्यायाम, उपवास, अनिद्रा, अत्यधिक शारीरिक श्रम',
      aushadha: 'Ashwagandha Churna, Bala Arishta, Mamsa Rasayana',
      aushadhaHi: 'अव्यगंधा चूर्ण, बलारिष्ट, मांस रसायन',
    ),

    // Meda Vriddhi
    Recommendation(
      dhatu: 'Meda',
      condition: 'Vriddhi',
      pathyaAahar: 'Low-fat diet, barley, millets, honey, roasted chickpea, hot drinking water, green tea',
      pathyaAaharHi: 'कम वसा वाला भोजन, जौ, बाजरा, शहद, भुना हुआ चना, गर्म पीने का पानी, हरी चाय',
      apathyaAahar: 'Fried food, sweets, butter, ghee, cold drinks, fast food, heavy rice meals',
      apathyaAaharHi: 'तला हुआ भोजन, मीठा, मक्खन, घी, ठंडे पेय, फास्ट फूड, भारी चावल का भोजन',
      pathyaVihara: 'Brisk walking, aerobic exercises, yoga (Surya Namaskar), dynamic lifestyle',
      pathyaViharaHi: 'तेज चलना, एरोबिक व्यायाम, योग (सूर्य नमस्कार), गतिशील जीवनशैली',
      pathyaVihara: 'Sedentary habits, sleeping immediately after meals, day sleeping',
      pathyaViharaHi: 'निष्क्रिय आदतें, भोजन के तुरंत बाद सोना, दिन में सोना',
      aushadha: 'Medohar Guggulu, Triphala Guggulu, Lekhaniya Gana Vati',
      aushadhaHi: 'मेदोहर गुग्गुलु, त्रिफला गुग्गुलु, लेखनीय गण वटी',
    ),
    // Meda Kshaya
    Recommendation(
      dhatu: 'Meda',
      condition: 'Kshaya',
      pathyaAahar: 'Healthy fats, cow\'s ghee, sesame oil, sweet dishes, dairy products, nuts, sweet fruits',
      pathyaAaharHi: 'स्वस्थ वसा, गाय का घी, तिल का तेल, मीठे व्यंजन, डेयरी उत्पाद, नट्स, मीठे फल',
      apathyaAahar: 'Bitter, dry, astringent tastes, fasting, dry foods, cold beverages',
      apathyaAaharHi: 'कड़वे, सूखे, कसैले स्वाद, उपवास, रूखा भोजन, ठंडे पेय',
      pathyaVihara: 'Warm oil baths, relaxation techniques, restorative yoga, meditation',
      pathyaViharaHi: 'गर्म तेल से स्नान, विश्राम तकनीक, पुनर्योजी योग, ध्यान',
      pathyaVihara: 'Excessive sweating, long running, high intensity cardio exercise',
      pathyaViharaHi: 'अत्यधिक पसीना बहाना, लंबी दौड़, उच्च तीव्रता वाला कार्डियो व्यायाम',
      aushadha: 'Ashwagandha, Shatavari Ghee, Medhya Rasayana',
      aushadhaHi: 'अश्वगंधा, शतावरी घृत, मेध्य रसायन',
    ),

    // Asthi Vriddhi
    Recommendation(
      dhatu: 'Asthi',
      condition: 'Vriddhi',
      pathyaAahar: 'Light, easily digestible foods, leafy greens, bitter gourd, fresh organic vegetables',
      pathyaAaharHi: 'हल्का, आसानी से पचने वाला भोजन, पत्तेदार सब्जियां, करेला, ताजी जैविक सब्जियां',
      apathyaAahar: 'Excess calcium-rich foods, heavy red meats, highly processed food, preserved snacks',
      apathyaAaharHi: 'अत्यधिक कैल्शियम युक्त भोजन, भारी लाल मांस, अत्यधिक प्रसंस्कृत भोजन, डिब्बाबंद स्नैक्स',
      pathyaVihara: 'Joint mobility exercises, swimming, moderate physical activity, light stretching',
      pathyaViharaHi: 'जोड़ों की गतिशीलता के व्यायाम, तैराकी, मध्यम शारीरिक गतिविधि, हल्की स्ट्रेचिंग',
      pathyaVihara: 'Extreme heavy lifting, static postures for long hours, over-sleeping',
      pathyaViharaHi: 'अत्यधिक भारी वजन उठाना, लंबे समय तक एक ही मुद्रा में रहना, अत्यधिक सोना',
      aushadha: 'Guggulu, Guduchi (Giloy), Shankhabhasma',
      aushadhaHi: 'गुग्गुलु, गिलोय, शंखभस्म',
    ),
    // Asthi Kshaya
    Recommendation(
      dhatu: 'Asthi',
      condition: 'Kshaya',
      pathyaAahar: 'Calcium-rich foods, sesame seeds, milk, ragi, vegetable soup, almonds, organic dairy',
      pathyaAaharHi: 'कैल्शियम से भरपूर भोजन, तिल, दूध, रागी, सब्जी का सूप, बादाम, जैविक डेयरी',
      apathyaAahar: 'Carbonated drinks, coffee, excessive salty and dry foods, smoking, white sugar',
      apathyaAaharHi: 'कार्बोनेटेड पेय, कॉफी, अत्यधिक नमकीन और सूखे भोजन, धूम्रपान, सफेद चीनी',
      pathyaVihara: 'Sunbathing in morning, weight-bearing exercises, regular oil massage (Abhyanga)',
      pathyaViharaHi: 'सुबह की धूप सेकना, वजन उठाने वाले व्यायाम, नियमित तेल मालिश (अभ्यंग)',
      pathyaVihara: 'Running on hard surfaces, excessive jumping, long distance cycling',
      pathyaViharaHi: 'कठोर सतहों पर दौड़ना, अत्यधिक कूदना, लंबी दूरी की साइकिल चलाना',
      aushadha: 'Lakshadi Guggulu, Asthishrinkhala, Gandha Taila',
      aushadhaHi: 'लाक्षादि गुग्गुलु, अस्थिशृंखला, गंध तैल',
    ),

    // Majja Vriddhi
    Recommendation(
      dhatu: 'Majja',
      condition: 'Vriddhi',
      pathyaAahar: 'Light meals, green gram (Moong dal), bitter vegetables, warm water with lemon',
      pathyaAaharHi: 'हल्का भोजन, मूंग की दाल, कड़वी सब्जियां, नींबू के साथ गर्म पानी',
      apathyaAahar: 'Heavy fats, processed dairy, bone marrow dishes, highly refined sugars',
      apathyaAaharHi: 'भारी वसा, प्रसंस्कृत डेयरी, मज्जा के व्यंजन, अत्यधिक परिष्कृत चीनी',
      pathyaVihara: 'Yoga, pranayama, active intellectual activities, mental puzzles',
      pathyaViharaHi: 'योग, प्राणायाम, सक्रिय बौद्धिक गतिविधियां, मानसिक पहेलियां',
      pathyaVihara: 'Sleep overindulgence, day sleeping, mental inactivity, lazy routine',
      pathyaViharaHi: 'अत्यधिक सोना, दिन में सोना, मानसिक निष्क्रियता, आलसी दिनचर्या',
      aushadha: 'Triphala, Musta, Chandraprabha Vati',
      aushadhaHi: 'त्रिकला, मुस्ता, चंद्रप्रभा वटी',
    ),
    // Majja Kshaya
    Recommendation(
      dhatu: 'Majja',
      condition: 'Kshaya',
      pathyaAahar: 'Milk with ghee, almonds, walnuts, bone broth, sweet and nourishing foods, raisins',
      pathyaAaharHi: 'घी के साथ दूध, बादाम, अखरोट, हड्डी का सूप, मीठे और पौष्टिक भोजन, किशमिश',
      apathyaAahar: 'Dry, light, bitter, astringent foods, stimulants like caffeine, alcohol',
      apathyaAaharHi: 'सूखे, हल्के, कड़वे, कसैले भोजन, कैफीन जैसे उत्तेजक पदार्थ, शराब',
      pathyaVihara: 'Warm oil massage to spine, meditation, sound deep sleep, yoga nidra',
      pathyaViharaHi: 'रीढ़ की हड्डी पर गर्म तेल की मालिश, ध्यान, गहरी नींद, योग निद्रा',
      pathyaVihara: 'Chronic mental stress, loud noise exposure, staying awake late at night',
      pathyaViharaHi: 'पुराना मानसिक तनाव, तेज आवाज में रहना, देर रात तक जागना',
      aushadha: 'Ashwagandha, Majja Ghrita, Saraswatarishta',
      aushadhaHi: 'अश्वगंधा, मज्जा घृत, सारस्वतारिष्ट',
    ),

    // Shukra Vriddhi
    Recommendation(
      dhatu: 'Shukra',
      condition: 'Vriddhi',
      pathyaAahar: 'Bitter, astringent tastes, light vegetarian food, cooling vegetables, green leafy vegetables',
      pathyaAaharHi: 'कड़वे, कसैले स्वाद, हल्का शाकाहारी भोजन, ठंडी सब्जियां, हरी पत्तेदार सब्जियां',
      apathyaAahar: 'Garlic, onions, eggs, spicy food, aphrodisiacs, red meat, excess sweet syrup',
      apathyaAaharHi: 'लहसुन, प्याज, अंडे, तीखा भोजन, कामोत्तेजक पदार्थ, लाल मांस, अत्यधिक मीठा सिरप',
      pathyaVihara: 'Creative expression, yoga, sublimation of energy, daily meditation, cold showers',
      pathyaViharaHi: 'रचनात्मक अभिव्यक्ति, योग, ऊर्जा का उदात्तीकरण, दैनिक ध्यान, ठंडे पानी से स्नान',
      pathyaVihara: 'Excess sexual stimulation, watching provocative content, sedentary habits',
      pathyaViharaHi: 'अत्यधिक यौन उत्तेजना, उत्तेजक सामग्री देखना, निष्क्रिय आदतें',
      aushadha: 'Chandraprabha Vati, Guduchi (Giloy), Gokshura',
      aushadhaHi: 'चंद्रप्रभा वटी, गिलोय, गोक्षुर',
    ),
    // Shukra Kshaya
    Recommendation(
      dhatu: 'Shukra',
      condition: 'Kshaya',
      pathyaAahar: 'Milk, cow\'s ghee, saffron, almonds, dates, sweet dishes, black gram (Urad dal), honey',
      pathyaAaharHi: 'दूध, गाय का घी, केसर, बादाम, खजूर, मीठे व्यंजन, उड़द की दाल, शहद',
      apathyaAahar: 'Very spicy, sour, dry, astringent foods, alcohol, smoking, dry red chili',
      apathyaAaharHi: 'बहुत तीखे, खट्टे, सूखे, कसैले भोजन, शराब, धूम्रपान, सूखी लाल मिर्च',
      pathyaVihara: 'Adequate rest, gentle oil massage, peaceful home environment, positive thoughts',
      pathyaViharaHi: 'पर्याप्त विश्राम, हल्की तेल मालिश, शांतिपूर्ण घरेलू वातावरण, सकारात्मक विचार',
      pathyaVihara: 'Excessive physical or mental stress, sleep deprivation, long fasting periods',
      pathyaViharaHi: 'अत्यधिक शारीरिक या मानसिक तनाव, नींद की कमी, लंबे उपवास काल',
      aushadha: 'Ashwagandha, Shatavari Churna, Kapikachhu (Kaunch Beej)',
      aushadhaHi: 'अश्वगंधा, शतावरी चूर्ण, कौंच बीज',
    ),
  ];

  static Recommendation? getRecommendation(String dhatu, String condition) {
    for (final r in recommendationTable) {
      if (r.dhatu == dhatu && r.condition == condition) {
        return r;
      }
    }
    return null;
  }
}
