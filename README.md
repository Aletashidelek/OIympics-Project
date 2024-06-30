# OIympics-Project
### About
- This sport data analysis project aims to explore the historical medal records in the Olympic Games so that to get an deeper understanding of the sport landscape/popularity/competitiveness in each country. This project is only a subset of a greater project focusing on the market research of the global sport landscape. The dataset was obtained from [***Kaggle***](https://www.kaggle.com/datasets/piterfm/olympic-games-medals-19862018/discussion/266373)

### **Purpose**
- The insight generated from this dataset will prepare our company (a customer based sport service company) to strategize our global expansion and direct resources towards market research on specific countries.

### **Business Questions To Answer**
- Find out the countries with highest sport competitiveness by looking at historical medal counts -  (so that our customer will approve the credibility)
- Find out the countries with highest competitiveness by sport ( To design the possible location of our product in different sports based on the competitiveness of different countries)
- Find out the most competitive sports of countries who are our existing partners (try to best utilize our connections)
- Find out the most competitive country in the specific sports in which we have existing resources. (try to best utilize our resources)

### **Feature Engineering**
Removing unnecassary columns and generate new columns
1. Remove column code(country-code),code3(country-code-3), url, and participant_title
2. Split the game column into two individual columns with host city and year
3. Deleted the countries that have little value to our project (countries/political entities that no longer exist). But we chose to combine Federal Republic of Germany and German Democratic Republic with Germany because unlike Soviet Union, its heritage remains within border
    
   
