// Inspeção local sem rede: usa Edge já instalado, sem baixar navegador.
const fs=require('fs'), path=require('path'), {pathToFileURL,fileURLToPath}=require('url');
const {chromium}=require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const root=path.resolve(__dirname,'..'), site=path.join(root,'_site');
const out=path.join(root,'internal','validacao');fs.mkdirSync(out,{recursive:true});
function files(dir){return fs.readdirSync(dir,{withFileTypes:true}).flatMap(x=>x.isDirectory()?files(path.join(dir,x.name)):[path.join(dir,x.name)]);}
(async()=>{
 const browser=await chromium.launch({headless:true,channel:'msedge'});
 const context=await browser.newContext({viewport:{width:1440,height:1000},offline:true});
 const page=await context.newPage(); const report=[];
 const shots=new Set(['index.html','aulas/03-roteiro.html','aulas/05-roteiro.html','aulas/10-roteiro.html','aulas/11-roteiro.html','modelos/02-projeto-1.html','modelos/03-projeto-2.html','00-1-plano-ensino-oficial.html']);
 for(const file of files(site).filter(f=>f.endsWith('.html'))){
  const name=path.relative(site,file).replaceAll('\\','/');
  await page.goto(pathToFileURL(file).href,{waitUntil:'load'});
  const result=await page.evaluate(()=>({title:document.title,
    images:[...document.images].map(i=>({ok:i.complete&&i.naturalWidth>0,w:i.naturalWidth,h:i.naturalHeight})),
    tables:document.querySelectorAll('table').length,
    links:[...document.querySelectorAll('a[href]')].map(a=>a.href),
    errorText:/Execution halted|Quitting from|Error in /.test(document.querySelector('main')?.innerText||'')}));
  const broken=result.links.filter(h=>h.startsWith('file:')).filter(h=>{
   try{return !fs.existsSync(fileURLToPath(h.split('#')[0].split('?')[0]));}catch{return true;}
  });
  report.push({arquivo:name,title:result.title,figuras:result.images.length,tabelas:result.tables,
   figuras_validas:result.images.every(i=>i.ok),links_quebrados:[...new Set(broken)],erro_execucao:result.errorText});
  if(shots.has(name)){
   await page.screenshot({path:path.join(out,name.replaceAll('/','-')+'.png'),fullPage:false});
   const figure=page.locator('.cell-output-display img').first();
   if(await figure.count()) await figure.screenshot({path:path.join(out,name.replaceAll('/','-')+'-figura.png')});
  }
 }
 fs.writeFileSync(path.join(out,'html.json'),JSON.stringify(report,null,2));
 await browser.close();
 if(report.length<39) throw new Error(`HTML incompleto: ${report.length}, esperados pelo menos 39.`);
 const bad=report.filter(r=>!r.figuras_validas||r.links_quebrados.length||r.erro_execucao);
 console.log(JSON.stringify({html:report.length,figuras:report.reduce((a,r)=>a+r.figuras,0),falhas:bad},null,2));
 process.exitCode=bad.length?1:0;
})().catch(e=>{console.error(e);process.exit(1)});
