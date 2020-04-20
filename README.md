
# Csődelőrejelzés Többáltozós Statisztikai Módszerekkel
A csődelőrejelzés alapvető célja csődvalószínűség, illetve fizetőképességet kifejező score becslése az egyes megfigyelésekhez a magyarázó változók (pénzügyi mutatók) és a csődeseményt kifejező bináris célváltozó felhasználásával.

## Csődmodellezési Adatbázis Építés

Az adatgyűjtés tárgya a modell alkalmazásához várható célportfolióra reprezentatív adatbázis összeállítása. Ez a folyamat a következő feladatokat foglalja magában:

**1. Az adatbázis elemzése alapvető leíró statisztikai jellemzők alapján** <br>
**2. Pénzügyi mutató input változók megképzése** <br>
**3. Hiányzó értékek, nullával való osztások kezelése imputációs módszerekkel** <br>
**4. Bináris célváltozó (1/0 csődesemény) megképzése** <br>
**5. Outlier értékek azonosítása és csonkolással történő kezelése**

A kiinduló adatbázist a `database.xlsx` file-ból olvassuk be egy `rawdata` nevű dataframe-be.


```python
import matplotlib.pyplot as plt
import statistics as stats
import numpy as np
import pandas as pd
import math

rawdata = pd.read_excel('database.xlsx').fillna(0)

rawdata.head()
```




<div>
<table class="dataframe">  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>BeszamoloTip</th>
      <th>AllapotLeiras</th>
      <th>FotevTEAOR</th>
      <th>TeaorMegnevezes</th>
      <th>MerlegFoossz</th>
      <th>Arbevetel</th>
      <th>SajatToke</th>
      <th>AdozasUtEred</th>
      <th>UzemiUzletiTevEred</th>
      <th>ErtekcsokkLeir</th>
      <th>...</th>
      <th>Keszletek</th>
      <th>KovetelesekVevok</th>
      <th>KovetelesekSzallitok</th>
      <th>RovidLejKot</th>
      <th>HosszuLejKot</th>
      <th>ElozoMerlegFoosszeg</th>
      <th>ElozoSajatToke</th>
      <th>ElozoArbevetel</th>
      <th>ElozoPenzBeszEv</th>
      <th>PenzBeszEv</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Egyszerűsített éves beszámoló (T 1711 AB) ERED...</td>
      <td>Működik</td>
      <td>4520</td>
      <td>Gépjárműjavítás, -karbantartás</td>
      <td>75262</td>
      <td>20021</td>
      <td>35321</td>
      <td>925</td>
      <td>1650</td>
      <td>375.0</td>
      <td>...</td>
      <td>1105</td>
      <td>190</td>
      <td>39941.0</td>
      <td>9941</td>
      <td>30000</td>
      <td>43555</td>
      <td>24309</td>
      <td>21590</td>
      <td>2013</td>
      <td>2014</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Egyszerűsített éves beszámoló összköltség eljá...</td>
      <td>Működik</td>
      <td>7112</td>
      <td>Mérnöki tevékenység, műszaki tanácsadás</td>
      <td>23341</td>
      <td>131493</td>
      <td>2230</td>
      <td>75443</td>
      <td>84123</td>
      <td>509.0</td>
      <td>...</td>
      <td>0</td>
      <td>18952</td>
      <td>21042.0</td>
      <td>21042</td>
      <td>0</td>
      <td>45304</td>
      <td>2557</td>
      <td>130186</td>
      <td>2013</td>
      <td>2014</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Egyszerűsített éves beszámoló (T 1711 AB) ERED...</td>
      <td>Működik</td>
      <td>4520</td>
      <td>Gépjárműjavítás, -karbantartás</td>
      <td>16100</td>
      <td>42927</td>
      <td>4973</td>
      <td>616</td>
      <td>684</td>
      <td>200.0</td>
      <td>...</td>
      <td>1413</td>
      <td>10879</td>
      <td>11127.0</td>
      <td>9704</td>
      <td>1423</td>
      <td>15230</td>
      <td>4356</td>
      <td>38098</td>
      <td>2013</td>
      <td>2014</td>
    </tr>
    <tr>
      <th>3</th>
      <td>Éves beszámoló (T 1710 AB) EREDMÉNYKIMUTATÁS/É...</td>
      <td>Működik</td>
      <td>2823</td>
      <td>Irodagép gyártása (kivéve: számítógép és perif...</td>
      <td>473527</td>
      <td>562055</td>
      <td>433425</td>
      <td>22970</td>
      <td>23854</td>
      <td>12383.0</td>
      <td>...</td>
      <td>47761</td>
      <td>92124</td>
      <td>37313.0</td>
      <td>37313</td>
      <td>0</td>
      <td>493642</td>
      <td>425954</td>
      <td>578729</td>
      <td>2013</td>
      <td>2014</td>
    </tr>
    <tr>
      <th>4</th>
      <td>Egyszerűsített éves beszámoló összköltség eljá...</td>
      <td>Működik</td>
      <td>9601</td>
      <td>Textil, szőrme mosása, tisztítása</td>
      <td>84019</td>
      <td>110389</td>
      <td>31587</td>
      <td>3109</td>
      <td>3791</td>
      <td>20753.0</td>
      <td>...</td>
      <td>1005</td>
      <td>18471</td>
      <td>45473.0</td>
      <td>35397</td>
      <td>10076</td>
      <td>54224</td>
      <td>22478</td>
      <td>70873</td>
      <td>2013</td>
      <td>2014</td>
    </tr>
  </tbody>
</table>
<p>5 rows × 25 columns</p>
</div>



## 1. Az adatbázis elemzése alapvető leíró statisztikai jellemzők alapján
Az adatbázis elemzésénél a darabszám, átlag, szórás, minimum, maximum valamint a 25%, 50% és 75% percentilisek kerültek kiszámításra az összes pénzügyi mutatószámhoz.


```python
summary = rawdata.describe().iloc[:,1:20]

pd.options.display.float_format = '{:.2f}'.format

summary
```




<div>
<table class="dataframe">  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>MerlegFoossz</th>
      <th>Arbevetel</th>
      <th>SajatToke</th>
      <th>AdozasUtEred</th>
      <th>UzemiUzletiTevEred</th>
      <th>ErtekcsokkLeir</th>
      <th>TargyiEszk</th>
      <th>BefEszk</th>
      <th>PenzEszk</th>
      <th>Ertekpapirok</th>
      <th>ForgoEszk</th>
      <th>Keszletek</th>
      <th>KovetelesekVevok</th>
      <th>KovetelesekSzallitok</th>
      <th>RovidLejKot</th>
      <th>HosszuLejKot</th>
      <th>ElozoMerlegFoosszeg</th>
      <th>ElozoSajatToke</th>
      <th>ElozoArbevetel</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>count</th>
      <td>1000.00</td>
      <td>1000.00</td>
      <td>1000.00</td>
      <td>1000.00</td>
      <td>1000.00</td>
      <td>1000.00</td>
      <td>1000.00</td>
      <td>1000.00</td>
      <td>1000.00</td>
      <td>1000.00</td>
      <td>1000.00</td>
      <td>1000.00</td>
      <td>1000.00</td>
      <td>1000.00</td>
      <td>1000.00</td>
      <td>1000.00</td>
      <td>1000.00</td>
      <td>1000.00</td>
      <td>1000.00</td>
    </tr>
    <tr>
      <th>mean</th>
      <td>467276.11</td>
      <td>412486.35</td>
      <td>233583.26</td>
      <td>-63672.63</td>
      <td>-56471.08</td>
      <td>16982.99</td>
      <td>169319.25</td>
      <td>187828.49</td>
      <td>22897.22</td>
      <td>2599.66</td>
      <td>261255.10</td>
      <td>46359.61</td>
      <td>189400.07</td>
      <td>211775.94</td>
      <td>125440.02</td>
      <td>70075.88</td>
      <td>462583.20</td>
      <td>261959.49</td>
      <td>394492.35</td>
    </tr>
    <tr>
      <th>std</th>
      <td>3852837.37</td>
      <td>4082148.40</td>
      <td>3069293.66</td>
      <td>2705483.40</td>
      <td>2763547.25</td>
      <td>203963.54</td>
      <td>1166287.50</td>
      <td>1194236.26</td>
      <td>85084.29</td>
      <td>32098.75</td>
      <td>3158575.80</td>
      <td>435026.79</td>
      <td>2997634.61</td>
      <td>1194094.57</td>
      <td>635485.94</td>
      <td>682586.36</td>
      <td>4812501.83</td>
      <td>4456089.54</td>
      <td>3497749.68</td>
    </tr>
    <tr>
      <th>min</th>
      <td>10026.00</td>
      <td>10016.00</td>
      <td>-3954139.00</td>
      <td>-83875550.00</td>
      <td>-85231763.00</td>
      <td>0.00</td>
      <td>0.00</td>
      <td>0.00</td>
      <td>0.00</td>
      <td>0.00</td>
      <td>29.00</td>
      <td>0.00</td>
      <td>0.00</td>
      <td>0.00</td>
      <td>0.00</td>
      <td>0.00</td>
      <td>0.00</td>
      <td>-275789.00</td>
      <td>0.00</td>
    </tr>
    <tr>
      <th>25%</th>
      <td>20647.75</td>
      <td>27917.00</td>
      <td>5188.75</td>
      <td>198.75</td>
      <td>345.25</td>
      <td>288.75</td>
      <td>902.25</td>
      <td>1163.50</td>
      <td>1287.00</td>
      <td>0.00</td>
      <td>12686.50</td>
      <td>0.00</td>
      <td>3001.00</td>
      <td>9644.25</td>
      <td>7295.25</td>
      <td>0.00</td>
      <td>15303.75</td>
      <td>3443.00</td>
      <td>20797.00</td>
    </tr>
    <tr>
      <th>50%</th>
      <td>43807.50</td>
      <td>59141.00</td>
      <td>14258.00</td>
      <td>2246.50</td>
      <td>3029.50</td>
      <td>1157.00</td>
      <td>6188.50</td>
      <td>7786.00</td>
      <td>4961.50</td>
      <td>0.00</td>
      <td>26047.50</td>
      <td>447.00</td>
      <td>11120.50</td>
      <td>22635.00</td>
      <td>17676.00</td>
      <td>0.00</td>
      <td>36411.00</td>
      <td>11095.00</td>
      <td>48124.50</td>
    </tr>
    <tr>
      <th>75%</th>
      <td>136305.00</td>
      <td>166946.50</td>
      <td>42680.00</td>
      <td>9770.25</td>
      <td>11259.00</td>
      <td>3623.75</td>
      <td>35919.75</td>
      <td>43812.50</td>
      <td>13096.25</td>
      <td>0.00</td>
      <td>65847.50</td>
      <td>8859.25</td>
      <td>31697.50</td>
      <td>78555.25</td>
      <td>57933.50</td>
      <td>4415.00</td>
      <td>113466.50</td>
      <td>40399.00</td>
      <td>136602.25</td>
    </tr>
    <tr>
      <th>max</th>
      <td>85786071.00</td>
      <td>124239296.00</td>
      <td>77984400.00</td>
      <td>15752789.00</td>
      <td>18636439.00</td>
      <td>6008926.00</td>
      <td>22458472.00</td>
      <td>23313842.00</td>
      <td>1115466.00</td>
      <td>822580.00</td>
      <td>84197553.00</td>
      <td>9219831.00</td>
      <td>84194336.00</td>
      <td>22801319.00</td>
      <td>12924803.00</td>
      <td>18834823.00</td>
      <td>137975662.00</td>
      <td>134713597.00</td>
      <td>104131231.00</td>
    </tr>
  </tbody>
</table>
</div>




```python
fig, axes = plt.subplots(ncols=2, figsize=(15, 6))

summary.loc['mean',:].plot.bar(ax=axes[0], title='Átlag')

summary.loc['std',:].plot.bar(ax=axes[1], title='Szórás');
```


![png](Bankruptcy_files/Bankruptcy_5_0.png)


## 2. Pénzügyi mutató input változók megképzése
Az alábbi függvények egy új data frame létrehozását szolgálják, mely a kiszámolt pénzügyi mutatószámokat foglalja magában. A szabálytalanul számolt (0-val való osztás, kettős negatív osztás, ...) értékek helyére az őket helyettesítő imputációs módszert jelölő konstansok kerülnek. A számítások után a konstansokból segédfüggvényekkel számolható a megfelelő imputációs módszerrel a helyettesítő érték. A gyakori helyettesítő szabályok alkalmazását a lent definiált függvények segítik.


```python
MIN_IMPUT = "MIN_IMPUT"
MAX_IMPUT = "MAX_IMPUT"
MEDIAN_IMPUT = "MEDIAN_IMPUT"

def fullImputated(numerator, denominator):
    if denominator == 0 and numerator > 0:
        return MAX_IMPUT
    elif denominator == 0 and numerator == 0:
        return MEDIAN_IMPUT
    elif denominator == 0 and numerator < 0:
        return MIN_IMPUT
    else:
        return numerator / denominator
    
def zeroDivisionImputated(numerator, denominator):
    if denominator == 0:
        return MAX_IMPUT
    else:
        return numerator / denominator
```

**Sajáttőke-arányos nyereség (ROE) számítása:** <br>
Adózott eredmény / Átlagos saját tőke


```python
def calcROE(data):
    result = []
    for index, row in data.iterrows():
        auEredm = row['AdozasUtEred']
        meanST = (row['SajatToke'] + row['ElozoSajatToke'])/2
        if auEredm < 0 and meanST < 0:
            result.append(MIN_IMPUT)
        elif meanST == 0:
            result.append(MIN_IMPUT)
        else:
            result.append(auEredm / meanST)
    return result
```

**Eszközarányos nyereség (ROA):** <br>
Adózott eredmény / Átlagos mérlegfőösszeg


```python
def calcROA(data):
    meanMFO = (data['MerlegFoossz'] + data['ElozoMerlegFoosszeg'])/2
    return data['AdozasUtEred'] / meanMFO
```

**EBITDA jövedelmezőség:** <br>
(Üzemi tevékenység eredménye + Értékcsökkenési leírás) / Átlagos mérlegfőösszeg


```python
def calcEBITDA(data):
    result = []
    for index, row in data.iterrows():
        numer = row['UzemiUzletiTevEred'] + row['ErtekcsokkLeir']
        denom = (row['MerlegFoossz'] + row['ElozoMerlegFoosszeg'])/2
        ans = fullImputated(numer, denom)
        result.append(ans)
    return result
```

**Árbevételarányos nyereség (ROS):** <br>
Üzemi (üzleti) tevékenység eredménye / Értékesítés nettó árbevétele


```python
def calcROS(data):
    numerator = data['UzemiUzletiTevEred'] + data['ErtekcsokkLeir']
    return numerator / data['Arbevetel']
```

**Árbevételarányos EBITDA:** <br>
(Üzemi (üzleti) tevékenység eredménye + Értékcsökkenési leírás) / Értékesítés nettó árbevétele 


```python
def calcARBEV_ARANYOS_EBITDA(data):
    result = []
    for index, row in data.iterrows():
        numer = row['UzemiUzletiTevEred'] + row['ErtekcsokkLeir']
        denom = row['Arbevetel']
        ans = fullImputated(numer, denom)
        result.append(ans)
    return result
```

**Eszközarányos árbevétel (fordulatszám):** <br>
Értékesítés nettó árbevétele / Átlagos mérlegfőösszeg


```python
def calcESZK_ARANYOS_ARBEV(data):
    result = []
    for index, row in data.iterrows():
        numer = row['Arbevetel']
        denom = (row['MerlegFoossz'] + row['ElozoMerlegFoosszeg'])/2
        ans = fullImputated(numer, denom)
        result.append(ans)
    return result
```

**Készletek forgási sebessége (fordulatszám):** <br>
Értékesítés nettó árbevétele / Átlagos készletállomány


```python
def calcKESZLET_FORG_SEB(data):
    result = []
    for index, row in data.iterrows():
        numer = row['Arbevetel']
        denom = row['Keszletek']
        ans = fullImputated(numer, denom)
        result.append(ans)
    return result
```

**Vevők forgási sebessége (fordulatszám):** <br>
Értékesítés nettó árbevétele / Átlagos vevőállomány


```python
def calcVEVO_FORG_SEB(data):
    result = []
    for index, row in data.iterrows():
        numer = row['Arbevetel']
        denom = row['KovetelesekVevok']
        ans = fullImputated(numer, denom)
        result.append(ans)
    return result
```

**Likviditási ráta:** <br>
Forgóeszközök / Rövid lejáratú kötelezettségek


```python
def calcLIKVID_RATA(data):
    result = []
    for index, row in data.iterrows():
        numer = row['ForgoEszk']
        denom = row['RovidLejKot']
        ans = zeroDivisionImputated(numer, denom)
        result.append(ans)
    return result
```

**Likviditási gyorsráta:** <br>
(Forgóeszközök - Készletek) / Rövid lejáratú kötelezettségek


```python
def calcLIKVID_GYORSRATA(data):
    result = []
    for index, row in data.iterrows():
        numer = row['ForgoEszk'] - row['Keszletek']
        denom = row['RovidLejKot']
        ans = zeroDivisionImputated(numer, denom)
        result.append(ans)
    return result
```

**Készpénz likviditás:** <br>
(Pénzeszközök + Értékpapírok) / Rövid lejáratú kötelezettségek


```python
def calcKESZPENZ_LIKVID(data):
    result = []
    for index, row in data.iterrows():
        numer = row['PenzEszk'] + row['Ertekpapirok']
        denom = row['RovidLejKot']
        ans = zeroDivisionImputated(numer, denom)
        result.append(ans)
    return result
```

**Dinamikus likviditás:** <br>
Üzemi (üzleti) tevékenység eredménye / Rövid lejáratú kötelezettségek


```python
def calcDINAMIKUS_LIKVID(data):
    result = []
    for index, row in data.iterrows():
        numer = row['UzemiUzletiTevEred']
        denom = row['RovidLejKot']
        ans = fullImputated(numer, denom)
        result.append(ans)
    return result
```

**Saját vagyon aránya:** <br>
Saját tőke / Mérlegfőösszeg


```python
def calcSAJAT_VAGYON_ARANYA(data):
    result = []
    for index, row in data.iterrows():
        numer = row['SajatToke']
        denom = row['MerlegFoossz']
        if denom == 0:
            result.append(MIN_IMPUT)
        else:
            result.append(numer/denom)
    return result
```

**Eladósodottság mértéke:** <br>
Kötelezettségek / Mérlegfőösszeg


```python
def calcELADOS_MERTEKE(data):
    result = []
    for index, row in data.iterrows():
        numer = row['RovidLejKot'] + row['HosszuLejKot']
        denom = row['MerlegFoossz']
        ans = zeroDivisionImputated(numer, denom)
        result.append(ans)
    return result
```

**Hosszú távú eladósodottság:**<br>
Hosszú lejáratú kötelezettségek / (Saját tőke + Hosszú lejáratú kötelezettségek)


```python
def calcHOSSZU_TAVU_ELADOS(data):
    result = []
    for index, row in data.iterrows():
        numer = row['HosszuLejKot']
        denom = row['SajatToke'] + row['HosszuLejKot']
        if denom <= 0:
            result.append(MAX_IMPUT)
        else:
            result.append(numer/denom)
    return result
```

**Idegen tőke / Saját tőke arány:** <br>
Kötelezettségek / Saját tőke


```python
def calcIDEGEN_SAJAT_TOKE_ARANY(data):
    result = []
    for index, row in data.iterrows():
        numer = row['RovidLejKot'] + row['HosszuLejKot']
        denom = row['SajatToke']
        if denom <= 0:
            result.append(MAX_IMPUT)
        else:
            result.append(numer/denom)
    return result
```

**Befektetett eszközök saját finanszírozása:** <br>
Saját tőke / Befektetett eszközök


```python
def calcBEFESZK_SAJAT_FIN(data):
    result = []
    for index, row in data.iterrows():
        numer = row['SajatToke']
        denom = row['BefEszk']
        if denom == 0 and numer <= 0:
            result.append(MIN_IMPUT)
        elif denom == 0 and numer > 0:
            result.append(MEDIAN_IMPUT)
        else:
            result.append(numer/denom)
    return result
```

**Befektetett eszközök idegen finanszírozása:** <br>
Hosszú lejáratú kötelezettségek / Befektetett eszközök


```python
def calcBEFESZK_IDEGEN_FIN(data):
    result = []
    for index, row in data.iterrows():
        numer = row['HosszuLejKot']
        denom = row['BefEszk']
        ans = zeroDivisionImputated(numer, denom)
        result.append(ans)
    return result
```

**Dinamikus jövedelmezőségi ráta (bruttó):** <br>
(Adózott eredmény + Értékcsökkenési leírás) / Átlagos mérlegfőösszeg


```python
def calcDIN_JOVED_RATA(data):
    result = []
    for index, row in data.iterrows():
        numer = row['AdozasUtEred'] + row['ErtekcsokkLeir']
        denom = (row['MerlegFoossz']+ row['ElozoMerlegFoosszeg'])/2
        ans = fullImputated(numer, denom)
        result.append(ans)
    return result
```

**Cash flow / összes tartozás:**<br>
(Adózott eredmény + Értékcsökkenési leírás) / (Hosszú lejáratú kötelezettségek + Rövid lejáratú kötelezettségek)


```python
def calcCASH_FLOW_TART_RATA(data):
    result = []
    for index, row in data.iterrows():
        numer = row['AdozasUtEred'] + row['ErtekcsokkLeir']
        denom = row['HosszuLejKot'] + row['RovidLejKot']
        ans = fullImputated(numer, denom)
        result.append(ans)
    return result
```

**Cash-flow / nettó árbevétel:**<br>
(Adózott eredmény + Értékcsökkenési leírás) / Értékesítés nettó árbevétele


```python
def calcCASH_FLOW_ARBEV_RATA(data):
    result = []
    for index, row in data.iterrows():
        numer = row['AdozasUtEred'] + row['ErtekcsokkLeir']
        denom = row['Arbevetel']
        ans = fullImputated(numer, denom)
        result.append(ans)
    return result
```

**Mérlegfőösszeg nagysága:** <br>
log (Mérlegfőösszeg)


```python
def calcMFO_NAGYSAG(data):
    return [math.log(x) for x in data['MerlegFoossz']]
```

**Éves árbevétel nagysága:** <br>
log (Értékesítés nettó árbevétele)


```python
def calcARBEV_NAGYSAG(data):
    return [math.log(x) for x in data['Arbevetel']]
```

**Árbevétel növekedési üteme:** <br>
Értékesítés nettó árbevétele tárgyidőszak / Értékesítés nettó árbevétele előző időszak


```python
def calcARBEV_NOVEK(data):
    result = []
    for index, row in data.iterrows():
        numer = row['Arbevetel']
        denom = row['ElozoArbevetel']
        if denom == 0 and numer >= 0:
            result.append(MEDIAN_IMPUT)
        else:
            result.append(numer/denom)
    return result
```

**Tőkeellátottsági mutató:** <br>
(Befektetett eszközök + Készletek) / Saját tőke


```python
def calcTOKE_ELLAT(data):
    result = []
    for index, row in data.iterrows():
        numer = row['BefEszk'] + row['Keszletek']
        denom = row['SajatToke']
        if denom == 0:
            result.append(MIN_IMPUT)
        else:
            result.append(numer/denom)
    return result
```

**Forgóeszközök aránya:**<br>
Forgóeszközök / Mérlegfőösszeg


```python
def calcFORGO_ESZK_ARANYA(data):
    result = []
    for index, row in data.iterrows():
        numer = row['ForgoEszk']
        denom = row['MerlegFoossz']
        ans = zeroDivisionImputated(numer, denom)
        result.append(ans)
    return result
```

**Likvid pénzeszközök aránya:** <br>
(Pénzeszközök + Értékpapírok) / Forgóeszközök


```python
def calcLIKVID_PENZESZK_ARANYA(data):
    result = []
    for index, row in data.iterrows():
        numer = row['PenzEszk'] + row['Ertekpapirok']
        denom = row['ForgoEszk']
        if denom == 0 and numer == 0:
            result.append(MEDIAN_IMPUT)
        else:
            result.append(numer/denom)
    return result
```

**Nettó forgótőke arány:** <br>
(Forgóeszközök - Rövid lejáratú kötelezettségek) / Mérlegfőösszeg


```python
def calcFORGO_TOKE_ARANY(data):
    result = []
    for index, row in data.iterrows():
        numer = row['ForgoEszk'] - row['RovidLejKot']
        denom = row['MerlegFoossz']
        ans = zeroDivisionImputated(numer, denom)
        result.append(ans)
    return result
```

**Vevők / Szállítók aránya:** <br>
Vevőkövetelések / Szállítói kötelezettségek


```python
def calcVEVO_SZALLITO_ARANY(data):
    result = []
    for index, row in data.iterrows():
        numer = row['KovetelesekVevok']
        denom = row['KovetelesekSzallitok']
        if denom == 0:
            result.append(MEDIAN_IMPUT)
        else:
            result.append(numer/denom)
    return result
```

## 3. Hiányzó értékek, nullával való osztások kezelése imputációs módszerekkel
A pénzügyi mutatók kiszámításának implementációja után el lehet végezni a konkrét imputációs módszerek végrehajtását. Az alábbi `applyImputations` függvény minden adatsorban a fent beírt imputációs módszert indikáló string konstansokat a megfelelő helyettesítő értékre cseréli. Az `imputationStats` segédfüggvény pedig megszámolja a különböző imputációs eljárások alkalmazását. 


```python
methods = {
    MIN_IMPUT: min,
    MAX_IMPUT: max,
    MEDIAN_IMPUT: stats.median
}

def applyImputations(arr):
    nums = [x for x in arr if type(x) is not str]
    for x in arr:
        if type(x) is str:
            yield methods[x](nums)
        else:
            yield x
```

Nincs más hátra mint előre! A fenti függvény segítségével elkészíthető a végelges data frame, mely az imputációs eljárásokkal generált pénzügyi mutatószámokat tárolja.


```python
database = pd.DataFrame()

factory = {
    'ROE': calcROE,
    'ROA': calcROA,
    'EBITDA': calcEBITDA,
    'ROS': calcROS,
    'ARBEV_ARANYOS_EBITDA': calcARBEV_ARANYOS_EBITDA,
    'ESZK_ARANYOS_ARBEV': calcESZK_ARANYOS_ARBEV,
    'KESZLET_FORG_SEB': calcKESZLET_FORG_SEB,
    'VEVO_FORG_SEB': calcVEVO_FORG_SEB,
    'LIKVID_RATA': calcLIKVID_RATA,
    'LIKVID_GYORSRATA': calcLIKVID_GYORSRATA,
    'KESZPENZ_LIKVID': calcKESZPENZ_LIKVID,
    'DINAMIKUS_LIKVID': calcDINAMIKUS_LIKVID,
    'SAJAT_VAGYON_ARANYA': calcSAJAT_VAGYON_ARANYA,
    'ELADOS_MERTEKE': calcELADOS_MERTEKE,
    'HOSSZU_TAVU_ELADOS': calcHOSSZU_TAVU_ELADOS,
    'IDEGEN_SAJAT_TOKE_ARANY': calcIDEGEN_SAJAT_TOKE_ARANY,
    'BEFESZK_SAJAT_FIN': calcBEFESZK_SAJAT_FIN,
    'BEFESZK_IDEGEN_FIN': calcBEFESZK_IDEGEN_FIN,
    'DIN_JOVED_RATA': calcDIN_JOVED_RATA,
    'CASH_FLOW_TART_RATA': calcCASH_FLOW_TART_RATA,
    'CASH_FLOW_ARBEV_RATA': calcCASH_FLOW_ARBEV_RATA,
    'MFO_NAGYSAG': calcMFO_NAGYSAG,
    'ARBEV_NAGYSAG': calcARBEV_NAGYSAG,
    'ARBEV_NOVEK': calcARBEV_NOVEK,
    'TOKE_ELLAT': calcTOKE_ELLAT,
    'FORGO_ESZK_ARANYA': calcFORGO_ESZK_ARANYA,
    'LIKVID_PENZESZK_ARANYA': calcLIKVID_PENZESZK_ARANYA,
    'FORGO_TOKE_ARANY': calcFORGO_TOKE_ARANY,
    'VEVO_SZALLITO_ARANY': calcVEVO_SZALLITO_ARANY
}

for key in factory:
    record = factory[key](rawdata)
    database[key] = [x for x in applyImputations(record)]
```

Az így kapott adatbázis tartalmazza a legfontosabb pénzügyi indikátorokat, melyek a modellünk input változóit képzik a továbbiakban. Az adatbázis első 5 rekordjának értékei lentebb láthatóak.


```python
database.head()
```




<div>
<table class="dataframe">  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>ROE</th>
      <th>ROA</th>
      <th>EBITDA</th>
      <th>ROS</th>
      <th>ARBEV_ARANYOS_EBITDA</th>
      <th>ESZK_ARANYOS_ARBEV</th>
      <th>KESZLET_FORG_SEB</th>
      <th>VEVO_FORG_SEB</th>
      <th>LIKVID_RATA</th>
      <th>LIKVID_GYORSRATA</th>
      <th>...</th>
      <th>CASH_FLOW_TART_RATA</th>
      <th>CASH_FLOW_ARBEV_RATA</th>
      <th>MFO_NAGYSAG</th>
      <th>ARBEV_NAGYSAG</th>
      <th>ARBEV_NOVEK</th>
      <th>TOKE_ELLAT</th>
      <th>FORGO_ESZK_ARANYA</th>
      <th>LIKVID_PENZESZK_ARANYA</th>
      <th>FORGO_TOKE_ARANY</th>
      <th>VEVO_SZALLITO_ARANY</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>0.03</td>
      <td>0.02</td>
      <td>0.03</td>
      <td>0.10</td>
      <td>0.10</td>
      <td>0.34</td>
      <td>18.12</td>
      <td>105.37</td>
      <td>0.23</td>
      <td>0.12</td>
      <td>...</td>
      <td>0.03</td>
      <td>0.06</td>
      <td>11.23</td>
      <td>9.90</td>
      <td>0.93</td>
      <td>2.10</td>
      <td>0.03</td>
      <td>0.43</td>
      <td>-0.10</td>
      <td>0.00</td>
    </tr>
    <tr>
      <th>1</th>
      <td>31.52</td>
      <td>2.20</td>
      <td>2.47</td>
      <td>0.64</td>
      <td>0.64</td>
      <td>3.83</td>
      <td>36045.43</td>
      <td>6.94</td>
      <td>1.10</td>
      <td>1.10</td>
      <td>...</td>
      <td>3.61</td>
      <td>0.58</td>
      <td>10.06</td>
      <td>11.79</td>
      <td>1.01</td>
      <td>0.02</td>
      <td>0.99</td>
      <td>0.18</td>
      <td>0.09</td>
      <td>0.90</td>
    </tr>
    <tr>
      <th>2</th>
      <td>0.13</td>
      <td>0.04</td>
      <td>0.06</td>
      <td>0.02</td>
      <td>0.02</td>
      <td>2.74</td>
      <td>30.38</td>
      <td>3.95</td>
      <td>1.33</td>
      <td>1.18</td>
      <td>...</td>
      <td>0.07</td>
      <td>0.02</td>
      <td>9.69</td>
      <td>10.67</td>
      <td>1.13</td>
      <td>0.93</td>
      <td>0.80</td>
      <td>0.04</td>
      <td>0.20</td>
      <td>0.98</td>
    </tr>
    <tr>
      <th>3</th>
      <td>0.05</td>
      <td>0.05</td>
      <td>0.07</td>
      <td>0.06</td>
      <td>0.06</td>
      <td>1.16</td>
      <td>11.77</td>
      <td>6.10</td>
      <td>9.13</td>
      <td>7.85</td>
      <td>...</td>
      <td>0.95</td>
      <td>0.06</td>
      <td>13.07</td>
      <td>13.24</td>
      <td>0.97</td>
      <td>0.40</td>
      <td>0.72</td>
      <td>0.59</td>
      <td>0.64</td>
      <td>2.47</td>
    </tr>
    <tr>
      <th>4</th>
      <td>0.12</td>
      <td>0.04</td>
      <td>0.36</td>
      <td>0.22</td>
      <td>0.22</td>
      <td>1.60</td>
      <td>109.84</td>
      <td>5.98</td>
      <td>0.57</td>
      <td>0.54</td>
      <td>...</td>
      <td>0.52</td>
      <td>0.22</td>
      <td>11.34</td>
      <td>11.61</td>
      <td>1.56</td>
      <td>1.57</td>
      <td>0.24</td>
      <td>0.03</td>
      <td>-0.18</td>
      <td>0.41</td>
    </tr>
  </tbody>
</table>
<p>5 rows × 29 columns</p>
</div>



## 4. Bináris célváltozó (1/0 csődesemény) megképzése
A célváltozó képzés a csődbe jutás (default-tá, fizetésképtelenné válás) definícióján alapul, és bináris változót jelent. A cég csődös, ha valamely csődesemény bekövetkezett, ilyen lehet a csődeljárás, felszámolási eljárás, kényszertörlés megindítása, illetve legalább 90 napos hátralékos teljesítés bekövetkezése. A célváltozót ezen eseményekre vonatkozó információkból képezzük, melyek a beolvasott adatbázis `AllapotLeiras` oszlopában találhatóak.

Lássuk először a lehetséges értékeket:


```python
set(rawdata['AllapotLeiras'])
```




    {'A cég csőd eljárás alatt áll',
     'A cég felszámolási eljárás alatt áll',
     'A cég kényszertörlési eljárás alatt áll',
     'Működik'}



A különböző értékeket megszámolva, egy oszlopdiagramon meg tudjuk jeleníteni az egyes események előfordulásainak sokaságát:


```python
prettylabs = {
    'A cég csőd eljárás alatt áll': 'Csőd eljárás',
    'A cég felszámolási eljárás alatt áll': 'Felszámolás',
    'A cég kényszertörlési eljárás alatt áll': 'Kényszertörlés',
}

possibleEvents = prettylabs.keys()
events = list(rawdata['AllapotLeiras'])
counts = [events.count(x) for x in possibleEvents]
countmap = dict(zip(possibleEvents, counts))

indexes = [prettylabs[x] + f" ({countmap[x]})" for x in possibleEvents]

df = pd.DataFrame({'count': counts,}, index = indexes)

df.plot.bar(rot=0);
```


![png](Bankruptcy_files/Bankruptcy_76_0.png)


Látható, hogy a legtöbb csődesemény oka a felszámolási eljárás. Az eseményeket bináris változóvá transzfromálva ki tudjuk egészíteni az adatbázisunkat a fizetőképességet indikáló célváltozóval:


```python
binmap = {
    'A cég csőd eljárás alatt áll': 1,
    'A cég felszámolási eljárás alatt áll': 1,
    'A cég kényszertörlési eljárás alatt áll': 1,
    'Működik': 0
}

binlist = [binmap[x] for x in events]

database['CSOD'] = binlist

database.loc[96:101,["ROA","CSOD"]]
```




<div>
<table class="dataframe">  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>ROA</th>
      <th>CSOD</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>96</th>
      <td>-0.36</td>
      <td>0</td>
    </tr>
    <tr>
      <th>97</th>
      <td>0.03</td>
      <td>0</td>
    </tr>
    <tr>
      <th>98</th>
      <td>-0.06</td>
      <td>0</td>
    </tr>
    <tr>
      <th>99</th>
      <td>-0.04</td>
      <td>1</td>
    </tr>
    <tr>
      <th>100</th>
      <td>0.06</td>
      <td>0</td>
    </tr>
    <tr>
      <th>101</th>
      <td>0.01</td>
      <td>0</td>
    </tr>
  </tbody>
</table>
</div>



## 5. Outlier értékek azonosítása és csonkolással történő kezelése
Az outlier értékek olyan megfigyelt értékek, amelyek kilógnak a többi érték közül, nem tűnnek hihetőnek, túl nagyok, illetve túl kicsik. Az alapsokaság vagy a véletlen mintavétel általában nem hiba, hanem valós folyamatok révén tartalmaz outlier értékeket. Az outlier értékeket az alábbi kódrészlet a **percentilisek csonkolásával** szűri ki. A felső és alsó 5% precentilis-be eső értékeket a percentilis értékére változtatja.




```python
lower = dict(database.quantile(q=.05))
upper = dict(database.quantile(q=.95))

def truncate(vals, percentile, isUpper):
    for i in range(len(vals)):
        if isUpper and vals[i] > percentile:
            vals[i] = percentile
        elif not isUpper and vals[i] < percentile:
            vals[i] = percentile
```


```python
vals = list(database["ROS"])
percentile = lower["ROS"]
plt.plot(vals)
truncate(vals, percentile, False)
plt.plot(vals);
```


![png](Bankruptcy_files/Bankruptcy_81_0.png)


Az árbevételarányos nyereség pédáján jól látszik a csonkolás eredménye. A narancssárga szín jelzi az alsó 5% percentilis csonkolásából keletkezett adatokat. A kiugró értékek eltávolításával egy jóval reprezentatívabb adatsort nyerünk, mely alkalmasabb lesz a későbbiekben modellek készítésére.


```python
def truncateDatabase():
    for col in database:
        if col is 'FIZETOKEPES':
            continue
        else:
            vals = list(database[col])
            lowerp = lower[col]
            truncate(vals, lowerp, False)
            upperp = upper[col]
            truncate(vals, upperp, True)
            database[col] = vals
    
truncateDatabase()
```

Az outlier értékek kezelésével létrejött a végleges adatbázis, melyet a továbbiakban fel tudunk használni csődvalószínűség, illetve fizetőképességet kifejező score becslésére. A végleges táblát a `result.xslx` nevű állományba mentjük.


```python
database.to_excel("result.xlsx")
```
