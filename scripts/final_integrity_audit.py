"""
final_integrity_audit.py — internal integrity audit of CER-COD_data_v12_candidate.xlsx
Purely file-internal: no comparison against source papers.
Blocks: A structure/keys · B formula layer (engine + independent recompute) · C ranges/logic
        D vocabulary/artefact scan · E cross-sheet consistency
Output: PASS/WARN/FAIL per check, findings listed.
"""
import pandas as pd, numpy as np, subprocess, os, shutil, re

F='CER-COD_data_v12_candidate.xlsx'
d=pd.read_excel(F,'data'); lk=pd.read_excel(F,'lookup')
cmap=pd.read_excel(F,'country_map'); ss=pd.read_excel(F,'subsample_country_map')
ES='ES (corr_coeff)'; NF='sample_size\nno_firms_rounded'; NFY='sample_size\nno_firm-years_rounded'
res=[]
def chk(id_,desc,status,detail=''):
    res.append((id_,desc,status,detail))

# ---------- A structure & keys ----------
chk('A1','row count == 2852','PASS' if len(d)==2852 else 'FAIL',str(len(d)))
dup_out=d['outcome'].duplicated().sum()
chk('A2','outcome ids unique','PASS' if dup_out==0 else 'FAIL',f'{dup_out} duplicates')
in_lk=set(lk['study']); in_d=set(d['study'])
chk('A3','data study keys subset of lookup','PASS' if in_d<=in_lk else 'FAIL',str(sorted(in_d-in_lk))[:120])
chk('A4','all 120 lookup studies present in data','PASS' if in_lk<=in_d and len(in_lk)==120 else 'FAIL',
    f'lookup n={len(in_lk)}, unused={sorted(in_lk-in_d)[:3]}')
chk('A5','lookup cluster_id complete','PASS' if lk['cluster_id'].notna().all() else 'FAIL')
rk=set(d['row_skey'].dropna().astype(str))-{''}
chk('A6','row_skey values resolve in subsample_country_map','PASS' if rk<=set(ss['value'].astype(str)) else 'FAIL',
    str(sorted(rk-set(ss['value'].astype(str))))[:120])
ck=set(lk['ckey'].dropna().astype(str))
chk('A7','lookup ckey values resolve in country_map','PASS' if ck<=set(cmap['ckey'].astype(str)) else 'FAIL')
chk('A8','country_map country_str unique','PASS' if cmap['country_str'].is_unique else 'FAIL')
chk('A9','subsample_country_map value unique','PASS' if ss['value'].is_unique else 'FAIL')

# ---------- B formula layer ----------
os.makedirs('audit_tmp',exist_ok=True)
shutil.copy(F,'audit_tmp/f.xlsx')
subprocess.run(['soffice','--headless','--convert-to','xlsx','--outdir','audit_tmp/out','audit_tmp/f.xlsx'],
               capture_output=True)
rec=pd.read_excel('audit_tmp/out/f.xlsx','data')
def close(a,b):
    an=pd.to_numeric(a,errors='coerce'); bn=pd.to_numeric(b,errors='coerce')
    return bool(((np.isclose(an.fillna(-9),bn.fillna(-9),rtol=1e-9,atol=1e-9))|
                 (a.fillna('§').astype(str)==b.fillna('§').astype(str))).all())
GRID=['sample_mid','sample_median','sample_post share_2016','sample_post share_2017','sample_post share_2018',
 'sample_post share_2019','pp_share_lag0','pp_share_lag1','pp_share_lag2','pp_share_lag3','pp_mid_lag0',
 'pp_median_lag0','pp_end_lag0','pp_start_lag0','pp_window_class','pp_end_lag1','pp_end_lag2','pp_end_lag3',
 'pp_median split','pp_tertial split']
FORM=GRID+[NFY,'sample_start','sample_end','q_status','q_VHB','field',
           'country_region','country_econ','country_culture','country_legal']
bad=[c for c in FORM if not close(d[c],rec[c])]
chk('B1','engine recalculation == cached values (30 formula cols)','PASS' if not bad else 'FAIL',str(bad))
# independent recompute of every formula family
ds,de=d['d_sample_start'],d['d_sample_end']; ok=ds.notna()&de.notna(); mid=(ds+de)/2; L=(de-ds+1)
def share(cut): return ((de-cut+1)/L).clip(0,1)
tests={'sample_mid':mid,'sample_median':mid,
 'sample_post share_2016':share(2016),'sample_post share_2017':share(2017),
 'sample_post share_2018':share(2018),'sample_post share_2019':share(2019),
 'pp_share_lag0':share(2016),'pp_share_lag1':share(2017),'pp_share_lag2':share(2018),'pp_share_lag3':share(2019),
 'pp_mid_lag0':(mid>=2015.5).astype(float),'pp_median_lag0':(mid>=2016).astype(float),
 'pp_end_lag0':(de>=2016).astype(float),'pp_start_lag0':(ds>=2016).astype(float),
 'pp_end_lag1':(de>=2017).astype(float),'pp_end_lag2':(de>=2018).astype(float),'pp_end_lag3':(de>=2019).astype(float),
 'pp_median split':(mid>2013).astype(float),
 'pp_tertial split':(1+(mid>2011).astype(int)+(mid>2014).astype(int)).astype(float)}
bad=[]
for c,exp in tests.items():
    a=pd.to_numeric(d[c],errors='coerce')
    if not np.isclose(a[ok].fillna(-9),exp[ok].fillna(-9)).all(): bad.append(c)
wc=pd.Series(np.where(ds>=2016,'post-only',np.where(de<2016,'pre-only','mixed')),index=d.index)
if not (d['pp_window_class'][ok]==wc[ok]).all(): bad.append('pp_window_class')
chk('B2','grid values == independent python re-derivation','PASS' if not bad else 'FAIL',str(bad))
lkI=lk.set_index('study')
bad=[]
for col,lcol in [('q_status','q_status_class'),('q_VHB','q_vhb_class'),('field','field')]:
    if not (d[col].fillna('§').astype(str)==d['study'].map(lkI[lcol]).fillna('§').astype(str)).all(): bad.append(col)
chk('B3','q/field data cols == lookup classes','PASS' if not bad else 'FAIL',str(bad))
num=pd.to_numeric(d['n_obs'],errors='coerce'); proxy=d[NF]*(de-ds+1)
expE=num.where(num.notna(),proxy)
a=pd.to_numeric(d[NFY],errors='coerce')
chk('B4','col E == n_obs-else-proxy recompute','PASS' if np.isclose(a.fillna(-9),expE.fillna(-9)).all() else 'FAIL')
sv=ss.set_index('value'); EXC={'Bannier et al (2022)','Srivisal et al (2021)'}
bad=0
for dcol,lcol,mcol in [('country_region','c_region','region'),('country_econ','c_econ','econ'),
                       ('country_culture','c_culture','culture'),('country_legal','c_legal','legal')]:
    for i,row in d.iterrows():
        if row['study'] in EXC: continue
        k=row['row_skey']
        exp=(sv.at[k,mcol] if (pd.notna(k) and k in sv.index and pd.notna(sv.at[k,mcol])) else lkI.at[row['study'],lcol])
        if str(row[dcol])!=str(exp): bad+=1
chk('B5','country cols == subsample-else-paper recompute (excl. 2 hardcoded studies)','PASS' if bad==0 else 'FAIL',f'{bad} cells')

# ---------- C ranges & logic ----------
u=d['d_es_usable']==1
es=pd.to_numeric(d[ES],errors='coerce')
n_out=int(((es<-1)|(es>1))[u].sum())
chk('C1','usable ES within [-1,1]','PASS' if n_out==0 else 'FAIL',f'{n_out} out of range; max|r|={es[u].abs().max():.4f}')
chk('C2','d_sample_start <= d_sample_end','PASS' if (ds<=de)[ok].all() else 'FAIL')
yr=ok & ((ds<1980)|(de>2026))
chk('C3','sample years within [1980, 2026]','PASS' if int(yr.sum())==0 else 'WARN',f'{int(yr.sum())} rows outside')
sh=[c for c in GRID if 'share' in c]
bad=[c for c in sh if not pd.to_numeric(d[c],errors='coerce').dropna().between(0,1).all()]
chk('C4','all shares within [0,1]','PASS' if not bad else 'FAIL',str(bad))
chk('C5','d_es_usable == 1 iff ES present','PASS' if bool(((d[ES].notna())==(u)).all()) else 'FAIL')
nc=d['es_method']=='non-convertible'
chk('C6','non-convertible iff ES absent','PASS' if bool((nc==(d[ES].isna())).all()) else 'FAIL')
chk('C7','exactly 1 duplicate-tagged row','PASS' if int((d['duplicate']==1).sum())==1 else 'FAIL',
    str(int((d['duplicate']==1).sum())) if 'duplicate' in d.columns else 'col missing')
both=d[NF].notna()&expE.notna()
nlt=int((expE[both]<d[NF][both]).sum())
chk('C8','firm-years >= firms where both present','PASS' if nlt==0 else 'WARN',f'{nlt} rows with E < n_firms')

# ---------- D vocabulary & artefact scan ----------
CLOSED={'industry':{'non-sensitive','sensitive','99_NCE'},
 'regulation_sample_start':{'with ETS/CT','without ETS/CT','99_NCE'},
 'regulation_sample_end':{'with ETS/CT','without ETS/CT','99_NCE'},
 'country_region':{'1_US','2_Europe','3_AsiaPac','99_NCE'},
 'country_econ':{'1_developed','2_developing','99_NCE'},
 'country_culture':{'1_western','2_non_western','99_NCE'},
 'country_legal':{'1_common law','2_civil law','99_NCE'},
 'q_status':{'0_published','1_not published'},
 'q_VHB':{'1_VHB high','0_VHB low','99_NCE'},
 'field':{'1_fin/acc/econ','2_sust','3_mgmt'},
 'pp_window_class':{'pre-only','post-only','mixed'},
 'ES_measure':None,'CER_measure':None,'COD_instrument':None}
bad=[]
for c,allowed in CLOSED.items():
    if allowed is None: continue
    extra=set(d[c].dropna().astype(str).unique())-allowed
    if extra: bad.append((c,extra))
chk('D1','closed lists on all coded moderators','PASS' if not bad else 'FAIL',str(bad)[:200])
textcols=[c for c in d.columns if d[c].dtype==object]
flags={c:int((d[c].astype(str)=='FLAG').sum()) for c in textcols if (d[c].astype(str)=='FLAG').any()}
chk('D2',"remaining literal 'FLAG' cells",'WARN' if flags else 'PASS',str(flags))
ws_issues={}
for c in textcols:
    s=d[c].dropna().astype(str)
    n=int((s!=s.str.strip()).sum())
    if n: ws_issues[c]=n
chk('D3','leading/trailing whitespace in text cells','WARN' if ws_issues else 'PASS',str(ws_issues)[:200])
trunc={}
for c in ['CER_measure','COD_instrument','ES_measure','ES_source','d_country']:
    s=d[c].dropna().astype(str)
    t=s[s.str.endswith('(') | s.str.endswith(',')]
    if len(t): trunc[c]=sorted(t.unique())[:4]
chk('D4','truncation artefacts (trailing "("/",")','WARN' if trunc else 'PASS',str(trunc)[:220])
vocab_typos={}
for c in ['COD_instrument','CER_measure']:
    vals=sorted(d[c].dropna().astype(str).unique())
    sus=[v for v in vals if re.search(r'\bloand\b|  ',v)]
    if sus: vocab_typos[c]=sus
chk('D5','vocabulary typos (e.g. "loand", double spaces)','WARN' if vocab_typos else 'PASS',str(vocab_typos)[:220])
print()
COD_vals=sorted(d['COD_instrument'].dropna().astype(str).unique())

# ---------- E cross-sheet ----------
chk('E1','lookup q_status 120/120','PASS' if int(lk['q_status'].notna().sum())==120 else 'FAIL')
jif_ok=((lk['jif'].notna())|(lk['jif_note'].notna())).all()
chk('E2','every study has jif or jif_note','PASS' if bool(jif_ok) else 'FAIL')
prov=pd.read_excel(F,'provenance')
chk('E3','provenance rows == data rows','PASS' if len(prov)==len(d) else 'WARN',f'{len(prov)} vs {len(d)}')
chk('E4','field 120/120 in lookup','PASS' if int(lk['field'].notna().sum())==120 else 'FAIL')

# ---------- report ----------
print(f'{"ID":4s} {"STATUS":6s} CHECK')
nf=nw=0
for id_,desc,st,det in res:
    if st=='FAIL': nf+=1
    if st=='WARN': nw+=1
    print(f'{id_:4s} {st:6s} {desc}' + (f'  -> {det}' if det and st!="PASS" else ''))
print(f'\nSUMMARY: {len(res)} checks | FAIL {nf} | WARN {nw} | PASS {len(res)-nf-nw}')
print('\nCOD_instrument vocabulary:', COD_vals)
