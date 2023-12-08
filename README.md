# University
Databasteknik

Domänen som du kommer att modellera i denna uppgift är för kurser och studenter på ett universitet.

Universitetet är organiserat i:
1.Institutioner, till exempel institutionen för datavetenskap (Computer Science)
2. Utbildningsprogram för studenter, till exempel programmet för datavetenskap och teknik (Computer Science Engineering Program). 

Utbildningsprogrammen anordnas av institutioner, men flera institutioner kan samarbeta om ett program, vilket är fallet med programmet CSEP (Computer Science Engineering Program) som anordnas gemensamt av CS-institutionen och institutionen för datateknik (Computer Engineering). Institutionsnamn och förkortningar är unika, liksom programnamn men inte nödvändigtvis programförkortningar.

Varje program är vidare uppdelat i grenar, till exempel har CSEP grenarna Datorspråk, Algoritmer, Programvaruteknik etc. Observera att grennamn är unika inom ett visst program, men inte nödvändigtvis över flera program. Till exempel kan både CSEP och ett program i automationsteknik ha en gren som heter interaktionsdesign.

För varje program finns det obligatoriska kurser. För varje gren finns det ytterligare obligatoriska kurser som de studenter som läser den grenen måste läsa. Grenarna anger också en uppsättning rekommenderade kurser från vilka alla studenter som läser den grenen måste läsa en viss mängd för att uppfylla kraven för examen.

En student tillhör alltid ett program. Studenter måste välja en enda gren inom det programmet och uppfylla dess examenskrav för att kunna ta examen. Vanligtvis väljer studenterna vilken gren de ska läsa under sitt fjärde år, vilket innebär att studenter som befinner sig i början av sina studier kanske ännu inte tillhör någon gren.

Varje kurs ges av en institution (t.ex. CS ger kursen Databaser). Varje kurs har en unik kurskod på sex tecken. Alla kurser kan läsas av studenter från alla program. Vissa kurser kan vara obligatoriska för vissa program, men inte för andra. Studenter får högskolepoäng för godkända kurser, det exakta antalet kan variera mellan olika kurser (men alla studenter får samma antal poäng för samma kurs). Vissa, men inte alla, kurser har en begränsning av antalet studenter som får läsa kursen samtidigt.

Kurser kan klassificeras som antingen matematiska kurser, forskningskurser eller seminariekurser. Alla kurser behöver inte klassificeras, och vissa kurser kan ha mer än en klassificering. Universitetet kommer ibland att införa nya klassificeringar, så databasen måste tillåta detta. Vissa kurser har förkunskapskrav, dvs. andra kurser som måste klaras av innan en student får registrera sig på den.

Studenter måste registrera sig för kurser för att kunna läsa dem. För att få registrera sig måste studenten först uppfylla alla förkunskapskrav för kursen. Det ska inte vara möjligt för en student att registrera sig på en kurs om inte förkunskapskraven redan är godkända. Det ska inte vara möjligt för en student att registrera sig på en kurs som de redan har blivit godkända på.

Om en kurs blir fulltecknad sätts efteranmälda studenter upp på en väntelista. Om en av de tidigare registrerade studenterna bestämmer sig för att hoppa av, så att det finns en ledig plats på kursen, ges den platsen till den student som har väntat längst. När kursen är klar betygsätts alla studenter på en skala från "U", "3", "4", "5". Att få ett "U" innebär att studenten inte har klarat kursen, medan de andra betygen betecknar olika grader av framgång.

En studieadministratör (en person med direkt tillgång till databasen) kan åsidosätta både förkunskapskrav och storleksbegränsningar och lägga till en student direkt som registrerad på en kurs.








Din uppgift är att designa en databas enligt instruktioner nedan. Läs noga igenom domänbeskrivningen. Den är ganska komplex, så jag finns alltid här för att svara på frågor om domänen.

Uppgiften är indelad i flera steg och har en inlämning kopplad till varje steg. Allting lämnas in via LearnPoint.

Till uppgiften hör ett exempelschema och en domänbeskrivning som ni hittar på LearnPoint.

Uppgiften utförs i grupper om 2-3 studenter.

Uppgift 1 – ERD: 
Din första uppgift är att modellera databasen. Som tur är finns det ett schema som någon designat innan. Detta schema är dock inkomplett och behöver utökas för att korrekt modellera domänen.

1.	Kolla in det ofärdiga schemat.
2.	Skissa ett ER-diagram utifrån detta ofärdiga schema.
3.	Läs igenom domänbeskrivningen igen och utöka schemat för att bättre modellera domänen.
4.	Se till att ditt schema är normaliserat upp till 3NF.
Inläming: En bild över ditt schema.

Uppgift 2 – Implementera Tabellerna
Du ska nu implementera ditt ER-diagram med CREATE TABLE-statements och lämpliga PRIMARY och FOREIGN KEYS.

För att kolla igenom att du implementerat databasen rätt måste du testa dina constraints för olika scenarier. Dessa kan exempelvis vara:
•	Två grenar med samma namn, fast på olika program.
•	En student som inte har tagit några kurser.
•	En student som bara har fått underkänt.
•	En student som inte har valt någon gren.
•	En väntelista kan bara finnas för platsbegränsade kurser.
•	Och så vidare..
När du gjort detta kan du gå vidare till nästa uppgift.
Inlämning: en fil, tables.sql, som skapar alla tabeller.

Uppgift 3 – Views
Baserat på din tidigare databas ska du skapa följande views.

basic_information(idnr, name, program, branch) Visar information om alla studenter. Branch tillåts vara NULL.

finished_courses(student, course, grade, credits) Alla avslutade kurser för varje student, tillsammans med betyg och högskolepoäng.

passed_courses(student, course, credits) Alla godkända kurser för varje student.

registrations(student, course, status) Alla registrerade och väntande studenter för olika kurser. Statusen kan antingen vara ’waiting’ eller ’registered’.

unread_mandatory(student, course) Olästa obligatoriska kurser för varje student.

course_queue_position(course, student, place) Alla väntande studenter, rangordnade i turordning på väntelistan.

Om du har andra kolumner i dina views, dubbelkolla detta med mig. Dina views kan också vara godkända.

Inlämning: views.sql med definitionen för alla views.

Uppgift 4 – Frontend
Du ska nu skapa en enkel frontend för databasen. Du får själv välja vilken funktion detta ska vara. Det skulle till exempel kunna vara ett gränssnitt för en student att registrera sig på kurser. Det räcker att interagera med en av dina tabeller.

Du ska nu göra något högst ovanligt i den här uppgiften. Du ska medvetet introducera en möjlighet för att användaren att utföra en SQL-injection via din frontend. I kommentarer i koden anger du hur man skulle gå tillväga för att utnyttja den här svagheten. Kommentera också hur du skulle fixa detta.

Inlämning: En fil app.py eller en länk till GitHub-repo.
