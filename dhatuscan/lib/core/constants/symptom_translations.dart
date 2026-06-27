class SymptomTranslation {
  final String titleHindi;
  final String descEn;
  final String descHi;

  const SymptomTranslation({
    required this.titleHindi,
    required this.descEn,
    required this.descHi,
  });
}

class SymptomTranslations {
  static const Map<String, SymptomTranslation> translations = {
    // Rasa Vriddhi
    'Excessive Salivation': SymptomTranslation(
      titleHindi: 'अत्यधिक लार आना',
      descEn: 'Do you experience excessive salivation or drooling frequently?',
      descHi: 'क्या आपको बार-बार अधिक लार आना या मुँह से लार टपकने की समस्या होती है?',
    ),
    'Loss of Appetite': SymptomTranslation(
      titleHindi: 'भूख कम लगना',
      descEn: 'Have you noticed a decrease in appetite or lack of interest in eating?',
      descHi: 'क्या आपने अपनी भूख में कमी या खाने में रुचि कम होने का अनुभव किया है?',
    ),
    'Tastelessness': SymptomTranslation(
      titleHindi: 'स्वाद न आना',
      descEn: 'Do you feel a loss of taste or change in the taste of food?',
      descHi: 'क्या आपको खाने का स्वाद कम लग रहा है या स्वाद में बदलाव महसूस हो रहा है?',
    ),
    'Nausea': SymptomTranslation(
      titleHindi: 'मतली',
      descEn: 'Do you often feel nausea or a tendency to vomit?',
      descHi: 'क्या आपको अक्सर जी मिचलाना या उल्टी जैसा महसूस होता है?',
    ),
    'Obstruction of Channels': SymptomTranslation(
      titleHindi: 'स्रोतोरोध',
      descEn: 'Do you experience congestion or blockage affecting normal breathing or bodily functions?',
      descHi: 'क्या आपको सांस लेने या शरीर के सामान्य कार्यों में रुकावट या जाम जैसा महसूस होता है?',
    ),
    'Aversion to Sweet Taste': SymptomTranslation(
      titleHindi: 'मीठे से अरुचि',
      descEn: 'Do you have a dislike or aversion to sweet-tasting foods or drinks?',
      descHi: 'क्या आपको मीठा खाने या पीने में अरुचि या नापसंदगी महसूस होती है?',
    ),
    'Body Ache': SymptomTranslation(
      titleHindi: 'शरीर दर्द',
      descEn: 'Do you experience generalized body aches or muscle pain?',
      descHi: 'क्या आपको पूरे शरीर में दर्द या मांसपेशियों में दर्द महसूस होता है?',
    ),

    // Rasa Kshaya
    'Dryness': SymptomTranslation(
      titleHindi: 'सूखापन',
      descEn: 'Do you experience dryness or roughness in your skin/hair or mucous membrane?',
      descHi: 'क्या आपकी त्वचा, बाल या शरीर के अंदर सूखापन या खुरदरापन महसूस होता है?',
    ),
    'State of Illusion': SymptomTranslation(
      titleHindi: 'भ्रम',
      descEn: 'Do you feel dizziness or light-headedness frequently?',
      descHi: 'क्या आपको बार-बार चक्कर या हल्का-हल्का सिर घूमने जैसा महसूस होता है?',
    ),
    'Wasting': SymptomTranslation(
      titleHindi: 'मांसपेशियों का क्षय',
      descEn: 'Have you noticed unintentional weight loss or thinning of muscles?',
      descHi: 'क्या आपने बिना कारण वजन कम होना या मांसपेशियों का पतला होना महसूस किया है?',
    ),
    'Tiredness without work': SymptomTranslation(
      titleHindi: 'बिना काम के थकान',
      descEn: 'Do you often feel tired or unable to complete daily activities?',
      descHi: 'क्या आपको बिना ज्यादा काम किए ही थकान महसूस होती है या आप दैनिक कार्य पूरे नहीं कर पाते?',
    ),
    'Intolerance to Noise': SymptomTranslation(
      titleHindi: 'तेज आवाज से परेशानी',
      descEn: 'Are you highly sensitive or intolerant to loud sounds?',
      descHi: 'क्या आपको तेज आवाज से ज्यादा परेशानी या असहजता होती है?',
    ),
    'Palpitation/Tachycardia': SymptomTranslation(
      titleHindi: 'दिल की धड़कन तेज',
      descEn: 'Do you frequently feel palpitations or rapid heartbeat?',
      descHi: 'क्या आपको अक्सर दिल की धड़कन तेज या असामान्य महसूस होती है?',
    ),

    // Rakta Vriddhi
    'Skin Inflammation': SymptomTranslation(
      titleHindi: 'त्वचा में सूजन / त्वचा शोथ',
      descEn: 'Do you frequently suffer from skin inflammation or infections causing swelling and redness?',
      descHi: 'क्या आपको त्वचा में सूजन, लालिमा या संक्रमण की समस्या बार-बार होती है?',
    ),
    'Abscess/Boils': SymptomTranslation(
      titleHindi: 'फोड़ा / विद्रधि',
      descEn: 'Do you develop boils or abscesses with pus formation?',
      descHi: 'क्या आपके शरीर में फोड़े-फुंसी या मवाद वाले फोड़े बनते हैं?',
    ),
    'Skin Diseases': SymptomTranslation(
      titleHindi: 'त्वचा रोग / कुष्ठ',
      descEn: 'Do you frequently suffer from skin diseases such as rashes, eczema or allergic skin problems?',
      descHi: 'क्या आपको बार-बार त्वचा रोग जैसे रैशेज, एक्जिमा या एलर्जी होती है?',
    ),
    'Joint Inflammation': SymptomTranslation(
      titleHindi: 'संधिशोथ / गठिया',
      descEn: 'Do you experience symptoms of arthritis or joint inflammation?',
      descHi: 'क्या आपको जोड़ों में दर्द या सूजन (गठिया) की समस्या होती है?',
    ),
    'Bleeding Disorders': SymptomTranslation(
      titleHindi: 'रक्तस्राव / खून बहना',
      descEn: 'Have you been diagnosed with bleeding disorders or prolonged bleeding?',
      descHi: 'क्या आपको असामान्य या लंबे समय तक खून बहने की समस्या होती है?',
    ),
    'Abdominal Distension': SymptomTranslation(
      titleHindi: 'उदरशूल / पेट फूलना',
      descEn: 'Do you experience abdominal distension or bloating regularly?',
      descHi: 'क्या आपको पेट फूलने या गैस की समस्या रहती है?',
    ),
    'Gum Bleeding/Bruising': SymptomTranslation(
      titleHindi: 'मसूड़ों से खून / नीला पड़ना',
      descEn: 'Have you noticed bleeding from the gums or unexplained bruising?',
      descHi: 'क्या आपके मसूड़ों से खून आता है या शरीर पर बिना कारण नीले निशान बनते हैं?',
    ),
    'Hyperpigmentation': SymptomTranslation(
      titleHindi: 'त्वचा का काला पड़ना / वर्ण परिवर्तन',
      descEn: 'Do you experience hyperpigmentation or dark patches on your skin?',
      descHi: 'क्या आपकी त्वचा पर काले धब्बे या रंग में परिवर्तन दिखाई देता है?',
    ),
    'Digestive Disturbances': SymptomTranslation(
      titleHindi: 'पाचन विकार / अग्निमांद्य',
      descEn: 'Do you suffer from digestive disturbances such as loss of appetite or acidity imbalance?',
      descHi: 'क्या आपको भूख कम लगना या पाचन संबंधी समस्या रहती है?',
    ),
    'Redness of Skin': SymptomTranslation(
      titleHindi: 'त्वचा की लालिमा',
      descEn: 'Do you often observe redness or inflammation of skin even with minor triggers?',
      descHi: 'क्या छोटी-छोटी बातों पर आपकी त्वचा लाल या सूजी हुई दिखाई देती है?',
    ),
    'Redness of Eyes': SymptomTranslation(
      titleHindi: 'आंखों की लालिमा',
      descEn: 'Do you notice increased redness or irritation in your eyes?',
      descHi: 'क्या आपकी आंखों में लालिमा या जलन रहती है?',
    ),
    'Blood in Urine': SymptomTranslation(
      titleHindi: 'मूत्र में रक्त / रक्तमूत्र',
      descEn: 'Have you experienced red-coloured urine or blood in urine without a known cause?',
      descHi: 'क्या आपको बिना किसी स्पष्ट कारण के मूत्र में खून दिखाई देता है?',
    ),

    // Rakta Kshaya
    'Desire for Sour Taste': SymptomTranslation(
      titleHindi: 'अम्लरस की इच्छा',
      descEn: 'Do you experience a strong desire for sour-tasting foods or drinks?',
      descHi: 'क्या आपको खट्टे स्वाद वाले भोजन या पेय पदार्थ खाने की तीव्र इच्छा होती है?',
    ),
    'Desire for Cold': SymptomTranslation(
      titleHindi: 'शीतप्रियता',
      descEn: 'Do you often feel a desire for cold things, especially in hot environments?',
      descHi: 'क्या आपको ठंडी चीजें या ठंडा वातावरण अधिक पसंद आता है?',
    ),
    'Loss of Elasticity in Veins/Skin': SymptomTranslation(
      titleHindi: 'शिरा-शैथिल्य',
      descEn: 'Do you notice loss of elasticity in skin or veins (especially with aging)?',
      descHi: 'क्या आपने देखा है कि आपकी त्वचा या नसों की लोच (elasticity) कम हो गई है?',
    ),
    'Skin Dryness': SymptomTranslation(
      titleHindi: 'त्वचा शुष्कता',
      descEn: 'Do you experience persistent dryness of the skin?',
      descHi: 'क्या आपकी त्वचा अक्सर सूखी रहती है?',
    ),

    // Mamsa Vriddhi
    'Cheek Flabbiness': SymptomTranslation(
      titleHindi: 'कपोल स्थूलता',
      descEn: 'Do you notice flabbiness or excessive fullness in your cheeks?',
      descHi: 'क्या आपके गालों में अधिक मांसलता या ढीलापन (Flabbiness) दिखाई देता है?',
    ),
    'Hypertrophy of Thigh Muscles': SymptomTranslation(
      titleHindi: 'असमृद्धि / ऊरु स्थूलता',
      descEn: 'Do you experience flabbiness or enlargement in your thighs?',
      descHi: 'क्या आपकी जांघों में असामान्य रूप से अधिक मांसलता या सूजन दिखाई देती है?',
    ),
    'Abdominal Enlargement': SymptomTranslation(
      titleHindi: 'उदर वृद्धि',
      descEn: 'Do you notice enlargement or excessive fullness in your abdomen?',
      descHi: 'क्या आपके पेट (उदर) में असामान्य वृद्धि या अधिक मांसलता दिखाई देती है?',
    ),
    'Tumor or Lump': SymptomTranslation(
      titleHindi: 'अर्बुद / ग्रन्थि',
      descEn: 'Have you noticed any lumps or tumor-like growth anywhere in your body?',
      descHi: 'क्या आपके शरीर में कहीं गांठ (Lump) या ट्यूमर जैसी वृद्धि महसूस होती है?',
    ),
    'Excess Fleshy Growth in Neck': SymptomTranslation(
      titleHindi: 'कण्ठादि अधिमांस',
      descEn: 'Do you experience excessive fleshy growth in your neck or other parts of the body?',
      descHi: 'क्या आपके गले (कण्ठ) या शरीर के अन्य भागों में अतिरिक्त मांस की वृद्धि दिखाई देती है?',
    ),

    // Mamsa Kshaya
    'Weakness in Eyes': SymptomTranslation(
      titleHindi: 'अक्षग्लानि',
      descEn: 'Do you experience fatigue or weakness in your sensory organs, especially the eyes?',
      descHi: 'क्या आपको अपनी इन्द्रियों, विशेषकर आँखों में कमजोरी या थकान महसूस होती है?',
    ),
    'Muscle Wasting of Cheeks/Buttocks': SymptomTranslation(
      titleHindi: 'गण्ड-स्फिक्-शुष्कता',
      descEn: 'Have you noticed a reduction in the size of your cheeks or buttocks?',
      descHi: 'क्या आपने अपने गालों या नितम्बों के आकार में कमी या सूखापन देखा है?',
    ),
    'Arthralgia': SymptomTranslation(
      titleHindi: 'सन्धिवेदना',
      descEn: 'Do you have joint pain?',
      descHi: 'क्या आपको जोड़ों में दर्द होता है?',
    ),

    // Meda Vriddhi
    'Tiredness with Palpitations': SymptomTranslation(
      titleHindi: 'श्रम:',
      descEn: 'Do you experience palpitations and fatigue even during mild exercise or physical activity?',
      descHi: 'क्या आपको हल्के व्यायाम या शारीरिक गतिविधि के दौरान भी थकान या धड़कन (palpitations) महसूस होती है?',
    ),
    'Shortness of Breath': SymptomTranslation(
      titleHindi: 'अल्पेऽपिचेष्टिते श्वास:',
      descEn: 'Do you experience shortness of breath even during mild physical activity or at rest?',
      descHi: 'क्या आपको कम परिश्रम या शारीरिक गतिविधि के दौरान भी सांस फूलने की समस्या होती है?',
    ),
    'Pendulous Overgrowth': SymptomTranslation(
      titleHindi: 'स्फिक्-स्तन-उदर लम्बनम्',
      descEn: 'Have you noticed excessive fat or overgrowth in the gluteal region, chest, or abdomen?',
      descHi: 'क्या आपने नितम्ब, स्तन या पेट के क्षेत्र में असामान्य रूप से अधिक चर्बी या वृद्धि देखी है?',
    ),
    'Very Oily Skin': SymptomTranslation(
      titleHindi: 'अतिस्निग्धता',
      descEn: 'Do you have very oily skin in all seasons?',
      descHi: 'क्या आपकी त्वचा सभी ऋतुओं में अत्यधिक तैलीय रहती है?',
    ),
    'Prodromal signs of Diabetes': SymptomTranslation(
      titleHindi: 'प्रमेह पूर्वरूप',
      descEn: 'Do you experience any prodromal signs of diabetes?',
      descHi: 'क्या आपको मधुमेह के शुरुआती लक्षण महसूस होते हैं?',
    ),

    // Meda Kshaya
    'Numbness in Lower Back': SymptomTranslation(
      titleHindi: 'स्वपनम् कट्या :',
      descEn: 'Do you experience numbness or loss of sensation in your lower back or lumbar region?',
      descHi: 'क्या आपको कमर के निचले भाग (कटि प्रदेश) में सुन्नपन या संवेदना में कमी महसूस होती है?',
    ),
    'Splenomegaly': SymptomTranslation(
      titleHindi: 'प्लीहा वृद्धि',
      descEn: 'Have you noticed any discomfort or fullness in the left upper part of your abdomen?',
      descHi: 'क्या आपको पेट के बाएँ ऊपरी भाग में भारीपन या असहजता महसूस होती है?',
    ),
    'Lean Built': SymptomTranslation(
      titleHindi: 'कृशाङ्गता',
      descEn: 'Have you experienced extreme thinness or significant weight loss?',
      descHi: 'क्या आपको अत्यधिक दुबलापन या अचानक वजन कम होने का अनुभव हुआ है?',
    ),

    // Asthi Vriddhi
    'Hypertrophy of Teeth/Extra Teeth': SymptomTranslation(
      titleHindi: 'दन्त वृद्धि / अतिरिक्त दाँत',
      descEn: 'Do you notice any extra teeth or calculus apart from the normal in your mouth?',
      descHi: 'क्या आपके मुँह में सामान्य से अधिक दाँत, दाँतों पर अधिक पथरी (calculus) या असामान्य वृद्धि दिखाई देती है?',
    ),
    'Hypertrophy of Bone': SymptomTranslation(
      titleHindi: 'अध्यास्थि',
      descEn: 'Have you noticed any unusual bone growth or areas where your bones seem larger or thicker than normal?',
      descHi: 'क्या आपने शरीर के किसी भाग में हड्डियों का असामान्य बढ़ना, मोटा होना या सूजन जैसी वृद्धि महसूस की है?',
    ),

    // Asthi Kshaya
    'Asthi Shoola (Bone Pain)': SymptomTranslation(
      titleHindi: 'अस्थिशूल',
      descEn: 'Have you experienced pricking or persistent pain in your bones?',
      descHi: 'क्या आपको हड्डियों में चुभन या लगातार दर्द महसूस होता है?',
    ),
    'Cracking/Breaking of Teeth': SymptomTranslation(
      titleHindi: 'दन्त भंगुरता',
      descEn: 'Have you noticed increased brittleness or easy breaking of your teeth?',
      descHi: 'क्या आपने अपने दाँतों में अधिक कमजोरी या आसानी से टूटने की समस्या देखी है?',
    ),
    'Hair Fall': SymptomTranslation(
      titleHindi: 'केशपतन',
      descEn: 'Have you experienced excessive hair fall recently?',
      descHi: 'क्या आपको हाल ही में अत्यधिक बाल झड़ने की समस्या हुई है?',
    ),
    'Brittleness of Nails': SymptomTranslation(
      titleHindi: 'नख भंगुरता',
      descEn: 'Have you noticed increased brittleness or frequent breaking of your nails?',
      descHi: 'क्या आपके नाखून कमजोर होकर बार-बार टूटते हैं?',
    ),

    // Majja Vriddhi
    'Heaviness in Eyes': SymptomTranslation(
      titleHindi: 'नेत्रगौरव',
      descEn: 'Do you feel heaviness or laziness in your eyes?',
      descHi: 'क्या आपको आँखों में भारीपन या सुस्ती महसूस होती है?',
    ),
    'Heaviness in Body': SymptomTranslation(
      titleHindi: 'अंगगौरव',
      descEn: 'Do you feel heaviness or sluggishness in your body?',
      descHi: 'क्या आपको शरीर में भारीपन या आलस्य महसूस होता है?',
    ),
    'Thick Joints/Fat around joints': SymptomTranslation(
      titleHindi: 'पर्वसु स्थूल मूलानि',
      descEn: 'Have you noticed unusual thickening or fat accumulation around your joints?',
      descHi: 'क्या आपने अपने जोड़ों के आसपास असामान्य मोटापा या चर्बी का जमाव देखा है?',
    ),

    // Majja Kshaya
    'Osteoporosis feeling': SymptomTranslation(
      titleHindi: 'अस्थि शौषिर्य',
      descEn: 'Have you noticed weakness or hollow feeling in your bones?',
      descHi: 'क्या आपको अपनी हड्डियों में कमजोरी या खोखलापन महसूस होता है?',
    ),
    'State of Illusion/Dizziness': SymptomTranslation(
      titleHindi: 'भ्रम',
      descEn: 'Do you often experience dizziness or a spinning sensation?',
      descHi: 'क्या आपको अक्सर चक्कर या सिर घूमने जैसा महसूस होता है?',
    ),
    'Timira Darshan (Blurred Vision)': SymptomTranslation(
      titleHindi: 'तिमिर दर्शन',
      descEn: 'Do you experience blurred or unclear vision?',
      descHi: 'क्या आपको धुंधला या अस्पष्ट दिखाई देता है?',
    ),

    // Shukra Vriddhi
    'Increased Libido': SymptomTranslation(
      titleHindi: 'कामेच्छा',
      descEn: 'Have you experienced increased sexual desire recently?',
      descHi: 'क्या आपको हाल ही में यौन इच्छा (कामेच्छा) में वृद्धि महसूस हुई है?',
    ),
    'Spermolith': SymptomTranslation(
      titleHindi: 'शुक्राश्मरी',
      descEn: 'Have you been diagnosed with stones in genital tract OR feel obstruction during semen/urine passage?',
      descHi: 'क्या आपको जननांग मार्ग में पथरी या वीर्य/मूत्र के निकलने में रुकावट महसूस होती है?',
    ),

    // Shukra Kshaya
    'Late Ejaculation': SymptomTranslation(
      titleHindi: 'विलंबित स्खलन',
      descEn: 'Do you experience delayed ejaculation?',
      descHi: 'क्या आपको स्खलन में देरी होती है?',
    ),
    'Blood in Semen': SymptomTranslation(
      titleHindi: 'वीर्य में रक्त',
      descEn: 'Do you notice blood in semen?',
      descHi: 'क्या आपको वीर्य में खून दिखाई देता है?',
    ),
    'Pain in Penis & Testes': SymptomTranslation(
      titleHindi: 'शिश्न व वृषण में दर्द',
      descEn: 'Do you feel pain in penis or testes?',
      descHi: 'क्या आपको शिश्न या अंडकोष में दर्द होता है?',
    ),
    'Burning Sensation': SymptomTranslation(
      titleHindi: 'दाह/जलन',
      descEn: 'Do you feel burning during urination or ejaculation?',
      descHi: 'क्या आपको पेशाब या स्खलन के समय जलन होती है?',
    ),
    'Xerostomia (Dry Mouth)': SymptomTranslation(
      titleHindi: 'मुख शोष / मुँह सूखना',
      descEn: 'Do you experience dryness in mouth?',
      descHi: 'क्या आपका मुँह सूखता रहता है?',
    ),
  };
}
