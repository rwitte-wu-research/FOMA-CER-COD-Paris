"""v11 assembly v2 — per docs/v11_assembly_spec.md (DEC-040). Fixes: Zhou-2018 key, Koelbel slope set, robust N parsing, log-N fallback (F37d edge), P12 moderators, verifier V1-V16."""
import pandas as pd, numpy as np, re, math, glob, os, unicodedata, json
from scipy import stats as st
BL=[]; RES={}
def log(s): BL.append(str(s)); print(s)
def num(x):
    s=str(x).strip().replace(' ','')
    if s in ('','nan','FLAG'): return np.nan
    if re.fullmatch(r'\d{1,3}([.,]\d{3})+',s): s=re.sub(r'[.,]','',s)
    else: s=s.replace(',','.')
    try: return float(s)
    except: return np.nan

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
new['n_row']=new['n_obs'].map(num)
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

sv={s:v.iloc[0] for s,v in adj[adj['Typ']=='VALUE-DIFF'].groupby('Studie')[V]}
ov=0
for k,verd in sv.items():
    if 'v10 korrekt' not in verd: continue
    vv=d10[d10['study']==k]; nn=new[new['v11_key']==k]; used=set()
    for _,vr in vv.iterrows():
        c=nn[~nn.index.isin(used)].copy(); c['dd']=(c['ES_final']-vr['ES (corr_coeff)']).abs(); c=c.sort_values('dd')
        if len(c) and 0.0006<c.iloc[0]['dd']<=0.02:
            new.loc[c.index[0],['ES_final','es_method']]=[vr['ES (corr_coeff)'],'v10-adopted']; used.add(c.index[0]); ov+=1
log(f"P6 overrides: {ov} (52 regulär + 13 strukturell-propagiert = 65 Soll)")

elig=adj[(adj['Typ']=='V10-ONLY') & adj[V].str.contains('v10 korrekt') & adj['Ursache_Klasse'].str.match('Einzelprüfung$|Unit-Frage|Versionsdrift')].copy()
elig['v10_ID']=pd.to_numeric(elig['v10_ID'])
ad=d10[d10['outcome'].isin(elig['v10_ID'])].merge(elig[['v10_ID','Ursache_Klasse']],left_on='outcome',right_on='v10_ID')
ad['source']=np.where(ad['Ursache_Klasse'].str.contains('Versionsdrift'),'v10_version','v10-adopted')
keep=[]
for _,r in ad.iterrows():
    if r['source']=='v10_version':
        stg=new[new['v11_key']==r['study']]
        if len(stg) and (stg['ES_final']-r['ES (corr_coeff)']).abs().min()<=0.0006: continue
    keep.append(r)
ad=pd.DataFrame(keep); log(f"P7 adoptions: +{len(ad)} (Dedup -{len(elig)-len(ad)})")

A=list(d10.columns); EXT=['x_direction','outcome_direction','b','SE','t','p','r_bivariate','n_obs','x_lag','estimation_method','se_clustering','subsample_dimension','subsample_value','subsample_start','subsample_end','table_no','panel_model','page','cell_quote','construct_label_verbatim','outcome_label_verbatim','corpus_segment','cluster_id','source','es_method','construct_variant','unit','duplicate','staging_file','v10_ID']
ncol=[c for c in A if 'sample_size' in c][0]; next_id=int(d10['outcome'].max())+1
rows=[]
for _,r in new.iterrows():
    ra=dict.fromkeys(A,''); ra.update({'study':r['v11_key'],'outcome':next_id,'ES (corr_coeff)':r['ES_final'],'ES_source':r['ES_source'],'ES_measure':'bivariate' if r['es_method']=='bivariate' else 'partial','CER_measure':r['CER_measure'],'COD_instrument':r['COD_instrument'],ncol:r['n_use']}); next_id+=1
    for c_ in ('sample_start','sample_end'):
        if c_ in A: ra[c_]=r.get(c_,'')
    e={k:r.get(k,'') for k in EXT[:-2]}; e.update({'staging_file':r['file'],'v10_ID':''})
    rows.append({**ra,**e})
for _,r in ad.iterrows():
    ra={c:r[c] for c in A}
    e=dict.fromkeys(EXT,''); e.update({'corpus_segment':'original','source':r['source'],'es_method':'v10-adopted','duplicate':0,'v10_ID':r['outcome'],'unit':'building/loan [R3]' if r['study']=='Eichholtz et al (2019)' else ''})
    rows.append({**ra,**e})
v11=pd.DataFrame(rows)
v11['cluster_id']=v11['study']
v11.loc[v11['study'].isin(['Sandra et al (2021)','Ofogbe et al (2021)']),'cluster_id']='CLUSTER Sandra/Ofogbe'
v11.loc[v11['study'].eq('Kleimeier, Viehs (2021)'),'cluster_id']='CLUSTER Kleimeier-Viehs'
v11.to_pickle('v11_prelim.pkl'); json.dump({'log':BL,'res':RES},open('buildlog.json','w'))
log(f"ASSEMBLED: {len(v11)} rows | estimation {int((v11['duplicate']==0).sum())} | Studien {v11['study'].nunique()}")
