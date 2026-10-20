import {mkdir,rm,writeFile,copyFile} from 'node:fs/promises';

// Keep the existing Worker build intact for Sites, then export only public pages.
await import('./build.mjs');
const {default:worker}=await import('../dist/server/index.js');
const origin='https://royal-icon-furnitures-studio.mashabakopano52.chatgpt.site';
await rm('public',{recursive:true,force:true});
await mkdir('public',{recursive:true});
for(const [route,file] of [['/','index.html'],['/payment-preview','payment-preview.html']]){
  const response=await worker.fetch(new Request(origin+route),{},{});
  if(response.status!==200)throw new Error(`Could not export ${route}`);
  await writeFile('public/'+file,await response.text());
}
for(const file of ['royal-icon-logo.jpg','favicon.svg'])await copyFile('source/'+file,'public/'+file);
console.log('Vercel public/ export ready. Payment and admin routes remain on the existing authenticated backend.');
