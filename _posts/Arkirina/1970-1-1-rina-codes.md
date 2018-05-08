---
layout: post
title: Arkirina's Code Archive
category: Arkirina
tags: code, misc
keywords: code
description: Code Archive
---

## Google Code-in 2018 Archive

其实只是个抓所有学生的简单爬虫啦

```javascript
let cio = require('cheerio'),
    req = require('request-promise-native').defaults( {
        agentClass: require('socks5-https-client/lib/Agent'),
        agentOptions: { socksHost: '127.0.0.1', socksPort: 1088 }
    } );

(async() => {
    let loop=true, tasksUrl=new Map,page=1;
    do {
        let tasksP;
        try{ 
            tasksP = await req.get( 'https://codein.withgoogle.com/archive/2017/organization/5739975890960384/task/?page='+page );
        } catch(e) { console.log(e);break; }
        let $ = cio.load(tasksP);
        let list = $('.task-definition-list-item');
        let added=0;
        for(let i=0;i<list.length;i++) {
            let title = list.eq(i).find('.task-definition__name').text(), url = list.eq(i).find('a').attr('href');
            tasksUrl.set( title, 'https://codein.withgoogle.com' + url );
            added++;
            console.log(title);
        }
        if( added !== list.length ) loop = false;
        page++;
    } while(loop);

    console.log('\x1b[31mFetching 2nd page...\x1b[0m');

    let urlKv, it = tasksUrl.entries(), stus = new Map;
    while( !(( urlKv = it.next() ).done) ) {
        let [ name, url ] = urlKv.value;
        process.stdout.write(`>>> \x1b[33m ${name}\x1b[0m: `);
        let page;
        try{
            page = await req.get( url );
        } catch(e) { process.stdout.write('\x1b[31m FAILED\x1b[0m\n'); continue; }
        let $ = cio.load( page );

        let students = $('h4.task-definition__students-subheader').next().text();

        process.stdout.write( students + '\n');
        stus.set( name, students );
    }

    process.stdout.write('\x1b[32mDONE\x1b[0m');

    require('fs').writeFileSync('drupal.json',JSON.stringify(Array.from( stus )));
})().catch(e => console.error(e));
```
