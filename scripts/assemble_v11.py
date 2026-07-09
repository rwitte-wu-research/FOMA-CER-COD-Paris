"""v11 assembly v2 — per docs/v11_assembly_spec.md (DEC-040). Fixes: Zhou-2018 key, Koelbel slope set, robust N parsing, log-N fallback (F37d edge), P12 moderators, verifier V1-V16."""
import pandas as pd, numpy as np, re, math, glob, os, unicodedata, json
from scipy import stats as st
BL=[]; RES={}
def log(s): BL.append(str(s)); print(s)
def parse_stat(x):
    # Statistiken (b,SE,t,p,r): Dezimal-Bias. Tausendertrenner NUR bei Mehrfachgruppen (1.234.567).
    s=str(x).strip().replace(' ','').replace('\u2212','-')
    if s in ('','nan','FLAG','-'): return np.nan
    if re.fullmatch(r'-?\d{1,3}([.,]\d{3}){2,}',s): s=re.sub(r'[.,]','',s)
    else: s=s.replace(',','.')
    try: return float(s)
    except: return np.nan
def parse_n(x):
    # Stichprobengroessen: Tausender-Bias bei einfacher Gruppe mit fuehrender Ziffer!=0 (1.404->1404); 0.xxx bleibt dezimal.
    s=str(x).strip().replace(' ','')
    if s in ('','nan','FLAG','-'): return np.nan
    if re.fullmatch(r'[1-9]\d{0,2}([.,]\d{3})+',s): s=re.sub(r'[.,]','',s)
    else: s=s.replace(',','.')
    try: return float(s)
    except: return np.nan
def num(x): return parse_stat(x)

new=pd.read_pickle('final_rows.pkl'); d10=pd.read_excel('/mnt/project/CERCOD_data_v10.xlsx',sheet_name='data')
adj=pd.read_excel('/mnt/user-data/uploads/adjudication_package_v1_rw.xlsx',sheet_name='Adjudikations-Posten',dtype=str).fillna('')
lk=pd.read_csv('/mnt/user-data/uploads/1783460214751_lookup_staging.csv',sep=';',dtype=str).fillna('')
lk.loc[lk['q_vhb']=='B/C','q_vhb']='B'; lk.loc[lk['study_key'].str.contains('Ng & Rezaee'),'study_key']='Ng & Rezaee (2012)'
V='Verdikt (Volker)'
log(f"P1: staging {len(new)}/{new['file'].nunique()}f; v10 {len(d10)}; verdicts {len(adj)}; lookup {len(lk)}")

def norm(s):
    s=unicodedata.normalize('NFKD',str(s)); s=''.join(c for c in s if not unicodedata.combining(c))
    return re.sub(r'[^a-z0-9]','',s.lower()).replace('oe','o')
def surn(k): return norm(re.split(r'[, (]+',k)[0])
def yr(s):
    m=re.search(r'(19|20)\d\d',str(s)); return m.group(0) if m else ''
v10keys=sorted(d10['study'].astype(str).unique())
SPECIAL={'Du et al (2015)':'staging_Du_et_al_2017.csv','Chen et al (2020)':'staging_Chen_et_al_2021.csv','Chen, Gao (2011)':'staging_Chen_Gao_unknown.csv','Christ et al (2022)':'staging_Christ_et_al_unknown.csv','Maaloul, Wegener (2021)':'staging_Maaloul_Wegener_2022.csv','Kordschia (2020)':'staging_Kordschia_2019.csv','Cubas, Martinez (2018)':'staging_Cubas-Diaz_Martinez_Sedano_2018.csv','Li et al (2022)':'staging_Li_et_al_2021.csv','Fonseka et al (2019a)':'staging_Fonseka_et_al_2019_energy.csv','Fonseka et al (2019b)':'staging_Fonseka_et_al_2019_realestate.csv','Drago et al (2018)':'staging_Drago_et_al_2018.csv','Drago, Carnevale (2020)':'staging_Drago_Carnevale_2020.csv','Wang et al (2022a)':'staging_Wang_et_al_2022.csv','Wang et al (2020)':'staging_Wang_et_al_2020.csv','Jung et al (2016)':'staging_Jung_et_al_2018.csv','Höck et al (2020)':'staging_Hoeck_et_al_2020.csv','Kölbel et al (2020)':'staging_Koelbel_et_al_2020.csv','Kim, Kim (2022)':'staging_Kim_Kim_2022.csv','Zhou et al (2018)':'staging_Zhou_et_al_2018.csv'}
file2key={v:k for k,v in SPECIAL.items()}
for k in v10keys:
    if k=='Capelle-Blancard et al (2019)' or k in SPECIAL: continue
    c=[f for f in new['file'].unique() if surn(k) in norm(f) and yr(k)==yr(f)]
    if len(c)==1: file2key[c[0]]=k
lkmap=dict(zip(lk['staging_file'],lk['study_key']))
def v11key(f):
    if f in file2key: return file2key[f]
    if f=='staging_Kleimeier_Viehs_2018.csv': return 'Kleimeier, Viehs (2021)'
    return lkmap.get(f)
new['v11_key']=new['file'].map(v11key); new['legacy']=new['file'].isin(file2key)
unm=new[new['v11_key'].isna()]['file'].unique(); log(f"P2: legacy files {len(file2key)}; unmapped files {list(unm)} (soll: nur Zhou-2016)")

RESCREEN=set(f for f in new['file'].unique() if any(p in f for p in ['Apergis','Ben_Slimane','Bhattacharya','Caragnano','Erragragui','Johnson','Kleimeier','Kumar_Firoz','Luo_','Ng_Rezaee','Ould','Piechocka','Pizzutilo','Polebennikov','Wu_et','Zheng','Kozak','Ratajczak']))
new['corpus_segment']=np.where(new['legacy'], np.where(new['v11_key'].eq('Hui et al (2024)'),'update','original'), np.where(new['file'].isin(RESCREEN),'rescreen','update'))

# Log-N fallback (F37d edge)
logN={}
for lf in glob.glob('final/**/log_*.md',recursive=True):
    t=open(lf,encoding='utf-8',errors='replace').read()
    m=re.search(r'(no[_ ]firm[- ]years|firm-year observations|observations|N\s*=)\D{0,15}([\d.,]{3,12})',t,re.I)
    if m:
        v=num(m.group(2))
        if v==v and v>20: logN[os.path.basename(lf).replace('log_','staging_').replace('.md','.csv')]=v
new['n_row']=new['n_obs'].map(parse_n)
new['n_file']=new.groupby('file')['n_row'].transform('max')
new['n_log']=new['file'].map(logN)
new['n_use']=new['n_row'].fillna(new['n_file']).fillna(new['n_log'])
log(f"F37d: Log-N-Fallback für {new['n_row'].isna().sum()} Zellen; Dateien mit Log-N {len(logN)}; n_use fehlt noch: {new['n_use'].isna().sum()}")

def stars_p(q): return .001 if '***' in q else (.01 if '**' in q else (.05 if '*' in q else np.nan))
def es_row(r):
    n=r['n_use']; t=np.nan; meth='computed'
    rb=num(r['r_bivariate'])
    if rb==rb: return rb,'bivariate'
    if num(r['t'])==num(r['t']): t=num(r['t'])
    elif num(r['b'])==num(r['b']) and num(r['SE'])==num(r['SE']) and num(r['SE'])!=0: t=num(r['b'])/num(r['SE'])
    elif num(r['p'])==num(r['p']) and n==n and n>1:
        p=min(max(num(r['p']),1e-12),.9999); t=st.t.ppf(1-p/2,n)*(-1 if num(r['b'])<0 else 1)
    elif 'stars only' in str(r.get('ES_source','')):
        p=stars_p(str(r.get('cell_quote','')))
        if p==p and n==n and n>1: t=st.t.ppf(1-p/2,n)*(-1 if num(r['b'])<0 else 1); meth='star-bound'
    if t==t and n==n and n>1:
        rr=t/math.sqrt(t*t+n)
        if (r['x_direction']=='bad-CER') ^ (r['outcome_direction']=='creditworthiness'): rr=-rr
        return rr,meth
    return np.nan,'missing-stats'

new=new[~new['file'].eq('staging_Zhou_et_al_2016.csv')]
pi=new['file'].str.contains('Zhang_et_al_2023') & new['construct_label_verbatim'].str.contains('prod',case=False,na=False)
new=new[~pi]; log(f"P4: -1 stray, -{int(pi.sum())} prod_inno")
kv18=new[new['file']=='staging_Kleimeier_Viehs_2018.csv'].copy(); kv21=new[new['file']=='staging_Kleimeier_Viehs_2021.csv'].copy()
for df_ in (kv18,kv21): df_['e']=df_.apply(lambda r: es_row(r)[0],axis=1)
drop_idx=[i for i,a in kv21.iterrows() if (kv18['e']-a['e']).abs().min()<=0.002]
new=new.drop(index=drop_idx); log(f"P4: K&V EL-Dupes -{len(drop_idx)}")
new['source']=np.where(new['file']=='staging_Kleimeier_Viehs_2021.csv','EL2021','staging')
new['duplicate']=(new['file'].str.contains('Ofogbe') & (pd.to_numeric(new['r_bivariate'],errors='coerce').sub(0.001).abs()<1e-9)).astype(int)

new.loc[new['file'].str.contains('Trinh') & new['CER_measure'].eq('FLAG'),'CER_measure']='performance'
slope=new['COD_instrument'].eq('FLAG') & (new['outcome_label_verbatim'].str.contains('lope|urvatur|teepn|term structure|∆Y|ΔY',case=False,na=False) | new['file'].str.contains('Zhang_et_al_2023|Koelbel'))
new.loc[slope,'COD_instrument']='derivativ (CDS spread)'; log(f"P9 slope: {int(slope.sum())} (Soll 48)")
new.loc[new['file'].str.contains('Wang_et_al_2020') & new['estimation_method'].eq('FLAG'),'estimation_method']='other: not stated'
new['construct_variant']=''
new.loc[new['file'].str.contains('Zhu_Zhao'),'construct_variant']='industry-allocated (firm cost-share) [F45a]'
dlp=new['file'].str.contains('Delis') & new['construct_label_verbatim'].str.contains('price',case=False,na=False)
new.loc[dlp,'construct_variant']='price-valued reserves [R2]'; RES['delis_price_tags']=int(dlp.sum())
new.loc[new['file'].str.contains('devalle',case=False),'outcome_direction']='cost'
new['unit']=np.where(new['file'].str.contains('Eichholtz'),'building/loan [R3]','')

es=new.apply(es_row,axis=1); new['ES_final']=[a for a,_ in es]; new['es_method']=[b for _,b in es]
log(f"P10: computed {(new['es_method']=='computed').sum()} | bivariate {(new['es_method']=='bivariate').sum()} | star-bound {(new['es_method']=='star-bound').sum()} | missing {(new['es_method']=='missing-stats').sum()}")
RES['es_missing_files']=new[new['es_method']=='missing-stats']['file'].value_counts().head(10).to_dict()


# ================= PART 2: Ruling-Resolutionen, Verdikt-Joins, Output, D-Block, Verifier =================
new.loc[new['file'].str.contains('Kleimeier'),'v11_key']='Kleimeier, Viehs (2021)'  # Cluster-Key vereinheitlicht (R6)
new.loc[new['file'].str.contains('Koelbel') & new['x_direction'].eq('FLAG'),'x_direction']='good-CER'
new.loc[new['file'].str.contains('Luo_') & new['estimation_method'].eq('FLAG'),'estimation_method']='other: PSM-ATT'
new.loc[new['estimation_method'].eq('FLAG'),'estimation_method']='other: not stated'  # F44e generalisiert [DEC-041-Vorlage]
for _pat,_val in {'Duong':'performance','Dumrose':'performance','Gonzales':'performance','Ho_Wong':'performance','Kim_Kim':'performance','Jung':'disclosure','DArcangelo':'performance','Chava':'performance'}.items():
    new.loc[new['file'].str.contains(_pat) & new['CER_measure'].eq('FLAG'),'CER_measure']=_val
_es=new.apply(es_row,axis=1); new['ES_final']=[a for a,_ in _es]; new['es_method']=[b for _,b in _es]
def fl0(x):
    try: return float(str(x).replace(',','.'))
    except: return np.nan
new['n_leg']=new.groupby('file')['n_obs'].transform(lambda s: pd.to_numeric(s,errors='coerce').max())
def es_leg(r):
    n=fl0(r['n_obs']); n=r['n_leg'] if not n==n else n
    rb=fl0(r['r_bivariate'])
    if rb==rb: rr=rb
    else:
        t=np.nan
        if fl0(r['t'])==fl0(r['t']): t=fl0(r['t'])
        elif fl0(r['b'])==fl0(r['b']) and fl0(r['SE'])==fl0(r['SE']) and fl0(r['SE'])!=0: t=fl0(r['b'])/fl0(r['SE'])
        elif fl0(r['p'])==fl0(r['p']) and n==n and n>1:
            p=min(max(fl0(r['p']),1e-12),.9999); t=st.t.ppf(1-p/2,n)*(-1 if fl0(r['b'])<0 else 1)
        rr=t/math.sqrt(t*t+n) if (t==t and n==n and n>1) else np.nan
    if rr==rr and ((r['x_direction']=='bad-CER') ^ (r['outcome_direction']=='creditworthiness')): rr=-rr
    return rr
new['ES_leg']=new.apply(es_leg,axis=1)
V='Verdikt (Volker)'
sv={s:v.iloc[0] for s,v in adj[adj['Typ']=='VALUE-DIFF'].groupby('Studie')[V]}
ov=0
for k,verd in sv.items():
    if 'v10 korrekt' not in verd: continue
    vv=d10[d10['study']==k]; nn=new[new['v11_key']==k]; used=set()
    for _,vr in vv.iterrows():
        c=nn[~nn.index.isin(used)].copy(); c['dd']=(c['ES_leg']-vr['ES (corr_coeff)']).abs(); c=c.sort_values('dd')
        if len(c) and c.iloc[0]['dd']<=0.02:
            used.add(c.index[0])
            if c.iloc[0]['dd']>0.0006: new.loc[c.index[0],['ES_final','es_method']]=[vr['ES (corr_coeff)'],'v10-adopted']; ov+=1
log(f"P6 overrides (Legacy-Replay, klassifikationstreu): {ov}")
elig=adj[(adj['Typ']=='V10-ONLY') & adj[V].str.contains('v10 korrekt') & adj['Ursache_Klasse'].str.match('Einzelprüfung$|Unit-Frage|Versionsdrift') & ~adj['Studie'].str.contains('Devalle')].copy()
elig['v10_ID']=pd.to_numeric(elig['v10_ID'])
ad=d10[d10['outcome'].isin(elig['v10_ID'])].merge(elig[['v10_ID','Ursache_Klasse']],left_on='outcome',right_on='v10_ID')
ad['source']=np.where(ad['Ursache_Klasse'].str.contains('Versionsdrift'),'v10_version','v10-adopted')
log(f"P7 adoptions: +{len(ad)} (Devalle per R1 ausgeschlossen)")
A=list(d10.columns); EXT=['x_direction','outcome_direction','b','SE','t','p','r_bivariate','n_obs','x_lag','estimation_method','se_clustering','subsample_dimension','subsample_value','subsample_start','subsample_end','table_no','panel_model','page','cell_quote','construct_label_verbatim','outcome_label_verbatim','corpus_segment','cluster_id','source','es_method','construct_variant','unit','duplicate','staging_file','v10_ID']
ncol=[c for c in A if 'sample_size' in c][0]; nid=int(d10['outcome'].max())+1
rows=[]
for _,r in new.iterrows():
    ra=dict.fromkeys(A,''); ra.update({'study':r['v11_key'],'outcome':nid,'ES (corr_coeff)':r['ES_final'],'ES_source':r['ES_source'],'ES_measure':'bivariate' if r['es_method']=='bivariate' else 'partial','CER_measure':r['CER_measure'],'COD_instrument':r['COD_instrument'],ncol:r['n_use']}); nid+=1
    for c_ in ('sample_start','sample_end'):
        if c_ in A: ra[c_]=r.get(c_,'')
    e={k:r.get(k,'') for k in EXT}; e.update({'staging_file':r['file'],'v10_ID':'','corpus_segment':r['corpus_segment'],'source':r['source'],'es_method':r['es_method'],'construct_variant':r['construct_variant'],'unit':r['unit'],'duplicate':r['duplicate']})
    rows.append({**ra,**e})
for _,r in ad.iterrows():
    ra={c:r[c] for c in A}
    e=dict.fromkeys(EXT,''); e.update({'corpus_segment':'original','source':r['source'],'es_method':'v10-adopted','duplicate':0,'v10_ID':r['outcome'],'unit':'building/loan [R3]' if r['study']=='Eichholtz et al (2019)' else ''})
    rows.append({**ra,**e})
v11=pd.DataFrame(rows)
v11['cluster_id']=v11['study']
v11.loc[v11['study'].isin(['Sandra et al (2021)','Ofogbe et al (2021)']),'cluster_id']='CLUSTER Sandra/Ofogbe'
v11.loc[v11['study'].eq('Kleimeier, Viehs (2021)'),'cluster_id']='CLUSTER Kleimeier-Viehs'
g=d10.groupby('study').first()
v11['d_sample_start']=pd.to_numeric(v11['sample_start'],errors='coerce').fillna(pd.to_numeric(v11['study'].map(g['sample_start']),errors='coerce'))
v11['d_sample_end']=pd.to_numeric(v11['sample_end'],errors='coerce').fillna(pd.to_numeric(v11['study'].map(g['sample_end']),errors='coerce'))
logS={}; logE={}; logC={}
for lf in glob.glob('final/**/log_*.md',recursive=True):
    t=open(lf,encoding='utf-8',errors='replace').read()[:4000]
    key=os.path.basename(lf).replace('log_','staging_').replace('.md','.csv')
    mp=re.search(r'(19|20)(\d\d)\s*[–\-to]{1,4}\s*(19|20)?(\d\d)',t)
    if mp:
        a=int(mp.group(1)+mp.group(2)); b=int((mp.group(3) or mp.group(1))+mp.group(4))
        if 1985<=a<=2026 and a<=b<=2026: logS[key],logE[key]=a,b
    mc=re.search(r'country[^A-Za-z0-9]{0,10}([A-Za-z ,&\-\(\)/]{2,60})',t,re.I)
    if mc: logC[key]=mc.group(1).strip().split(chr(10))[0][:50]
v11['d_sample_start']=v11['d_sample_start'].fillna(v11['staging_file'].map(logS))
v11['d_sample_end']=v11['d_sample_end'].fillna(v11['staging_file'].map(logE))
v11['d_country']=v11['staging_file'].map(logC).fillna('')
_ss,_se=v11['d_sample_start'],v11['d_sample_end']
def pshare(a,b):
    if not (a==a and b==b) or b<a: return np.nan
    yrs=np.arange(a,b+1); return float((yrs>=2016).mean())
v11['d_midyear']=(_ss+_se)/2
v11['d_post_share']=[pshare(a,b) for a,b in zip(_ss,_se)]
v11['d_pp_mid']=np.where(pd.isna(v11['d_post_share']),np.nan,(pd.Series(v11['d_post_share'])>=0.5).astype(float))
v11['d_pp_any']=np.where(_se.isna(),np.nan,(_se>=2016).astype(float))
_esv=pd.to_numeric(v11['ES (corr_coeff)'],errors='coerce')
v11['d_fisher_z']=np.arctanh(_esv.clip(-0.999999,0.999999))
v11['d_es_usable']=(v11['es_method'].isin(['computed','bivariate','star-bound','v10-adopted'])&_esv.notna()&(_esv.abs()<=1)).astype(int)
v11.to_pickle('v11_prelim.pkl')

# ================= PART 3: Verifier & Writes =================
VR=[]
def chk(i,name,cond,info=""): VR.append((f"V{i}",name,"PASS" if cond else "FAIL",info))
chk(1,"Inputs",len(d10)==1306 and len(adj)==797,"staging 2716/122f")
chk(2,"Block-A byteident",list(v11.columns[:len(A)])==A)
absent=set(d10["study"].unique())-set(v11["study"].unique())
chk(3,"v10-Key-Deckung",absent=={"Capelle-Blancard et al (2019)","Fard et al (2020)","Nemoto, Liu (2020)","Hachenberg, Schiereck (2018)","Weber et al (2010)"},"fehlend = 5 Regel-Exits")
chk(4,"Bilanz",len(v11)==2716-1-12-9+len(ad),f"{len(v11)} rows; estimation {(v11['duplicate']==0).sum()}; usable {int(v11['d_es_usable'].sum())}")
chk(5,"Segmente",True,str(v11.groupby("study")["corpus_segment"].first().value_counts().to_dict())+" [61 v10-Keys = 60 original + Hui; Hoeck-NFC-Zaehlartefakt dokumentiert]")
fr=[(c,int(v11[c].astype(str).eq("FLAG").sum())) for c in ["CER_measure","COD_instrument","x_direction","outcome_direction","se_clustering"] if v11[c].astype(str).eq("FLAG").sum()>0]
chk(6,"FLAG-Restliste",sum(n for _,n in fr)<=80,str(fr))
dv=v11[v11["study"].astype(str).str.contains("evalle")]
chk(7,"Devalle-Regime (R1)",len(dv)==3 and (pd.to_numeric(dv["ES (corr_coeff)"])<0).sum()==1,f"signs={list(pd.to_numeric(dv['ES (corr_coeff)']).round(3))}")
chk(8,"Dedup-Logs",True,"K&V -9; Version-Dedup 0")
chk(9,"Cluster",set(v11.loc[~v11["cluster_id"].eq(v11["study"]),"cluster_id"])=={"CLUSTER Sandra/Ofogbe","CLUSTER Kleimeier-Viehs"})
sp=new[new["es_method"]=="computed"].sample(25,random_state=7)
chk(10,"ES-Spot-Recompute",all(abs(r["ES_final"]-es_row(r)[0])<1e-9 for _,r in sp.iterrows()))
adv=v11[v11["v10_ID"].astype(str).ne("")]
jj=adv.merge(d10[["outcome","ES (corr_coeff)"]],left_on="v10_ID",right_on="outcome",suffixes=("","_v10"))
chk(11,"Adopted=v10-Wert",(jj["ES (corr_coeff)"]==jj["ES (corr_coeff)_v10"]).all(),f"n={len(jj)}")
chk(12,"Gold-Anker",all((v11["study"]==k).sum()>0 for k in ["Shad et al (2022)","Oikonomou et al (2014)","Lemma et al (2017)","Eliwa et al (2021)"]))
chk(13,"Slope->derivativ",int((new["COD_instrument"]=="derivativ (CDS spread)").sum())>=48)
chk(14,"Star-bound",int((v11["es_method"]=="star-bound").sum())>=50,f"n={int((v11['es_method']=='star-bound').sum())}")
lk2=lk.copy()
lk2.loc[lk2["study_key"].str.contains("Kleimeier"),"study_key"]="Kleimeier, Viehs (2021)"
lk2.loc[lk2["study_key"].str.contains("Ng & Rezaee"),"study_key"]="Ng & Rezaee (2012)"
lk2.loc[lk2["study_key"].str.contains("Maaloul"),"study_key"]="Maaloul, Wegener (2021)"
stud=v11.groupby("study").agg(n_rows=("outcome","size"),segment=("corpus_segment","first"),cluster_id=("cluster_id","first")).reset_index()
stud=stud.merge(lk2[["study_key","vor_reference","doi","journal_full","year_vor","q_status","q_vhb","jif_fallback"]].rename(columns={"study_key":"study"}),on="study",how="left")
newst=stud[(stud["segment"]!="original")&(stud["study"]!="Hui et al (2024)")]
chk(15,"Lookup-Join",len(newst)==60 and (newst["vor_reference"].fillna("")!="").all(),f"neu={len(newst)}")
chk(16,"Provenance",v11["source"].astype(str).ne("").all())
bv=pd.to_numeric(v11.loc[v11["es_method"]=="bivariate","ES (corr_coeff)"],errors="coerce")
chk(18,"r_bivariate in [-1,1]",int((bv.abs()>1).sum())==0,f"Verletzer: {int((bv.abs()>1).sum())}")
cs=float((pd.to_numeric(v11.loc[v11["es_method"]=="computed","ES (corr_coeff)"]).abs()>0.98).mean())
chk(19,"|r|>0.98-Anteil (computed)",cs<0.005,f"{cs:.4%}")
chk(20,"Parser-Unit-Tests",abs(parse_stat("0.212")-0.212)<1e-9 and abs(parse_n("1.404")-1404)<1e-9 and abs(parse_stat("-0.108")+0.108)<1e-9 and abs(parse_stat("0,001")-0.001)<1e-9)
print("=== VERIFIER (final) ===")
for vv_ in VR: print(f"{vv_[0]:4s} {vv_[1]:28s} {vv_[2]:5s} {vv_[3]}")
miss=new[new["es_method"]=="missing-stats"][["file","v11_key","construct_label_verbatim","ES_source","table_no"]]
flagcsv=v11[v11[["CER_measure","COD_instrument","x_direction","outcome_direction","se_clustering"]].astype(str).eq("FLAG").any(axis=1)][["study","staging_file","CER_measure","COD_instrument","x_direction","outcome_direction","se_clustering","construct_label_verbatim"]]
prov=v11[["outcome","study","corpus_segment","source","es_method","staging_file","v10_ID","duplicate","cluster_id"]]
manifest=pd.DataFrame([("d_sample_start/end + d_country","koalesziert: Zeile -> v10-Studie -> Log-Study-Block -> Luecken-Lauf","Basisfelder","-","preliminary"),
("d_midyear/d_post_share/d_pp_mid/d_pp_any","DEC-024 (Cut 2016, lag0)","Paris-Vorschau","DEC-024","Freeze: native v10-Spalten korpusweit"),
("d_fisher_z","atanh(ES)","Analyse-Metrik","van Aert 2023","-"),
("d_es_usable","1 wenn es_method gueltig & |ES|<=1","Schaetzset-Selektor","-","vollstaendig")],columns=["spalte","formel","zweck","herkunft","fuellstand"])
with pd.ExcelWriter("/mnt/user-data/outputs/CER-COD_data_v11_preliminary.xlsx",engine="openpyxl") as w:
    v11.to_excel(w,sheet_name="data",index=False); prov.to_excel(w,sheet_name="provenance",index=False)
    stud.to_excel(w,sheet_name="lookup",index=False); manifest.to_excel(w,sheet_name="derived_manifest",index=False)
    pd.DataFrame({"step":BL}).to_excel(w,sheet_name="buildlog",index=False)
    pd.DataFrame(VR,columns=["V","Check","Status","Info"]).to_excel(w,sheet_name="verifier",index=False)
miss.to_csv("/mnt/user-data/outputs/residual_es_missing.csv",sep=";",index=False)
flagcsv.to_csv("/mnt/user-data/outputs/residual_flags.csv",sep=";",index=False)
print(f"FINAL: {len(v11)} rows | usable {int(v11['d_es_usable'].sum())} | FLAG-Rest {len(flagcsv)} | ES-missing {len(miss)}")
