{ config }:
let
  inherit (config.myos.data) ports fqdn path;
in
rec {
  mixed-port = ports.clash-meta-mixed;

  allow-lan = false;

  ipv6 = true;

  external-controller = "127.0.0.1:${toString ports.clash-meta-api}";

  log-level = "warning";

  mode = "rule";

  dns = {
    enable = true;

    ipv6 = true;

    default-nameserver = [
      "223.5.5.5"
      "119.29.29.29"
    ];

    nameserver =
      [
        "https://doh.pub/dns-query"
        "https://dns.alidns.com/dns-query"
        "https://mozilla.cloudflare-dns.com/dns-query"
      ];

    enhanced-mode = "fake-ip";

    fake-ip-range = "198.18.0.1/16";

    fallback = [
      "tls://1.0.0.1:853"
      "https://cloudflare-dns.com/dns-query"
      "https://dns.google/dns-query"
      "tls://8.8.4.4:853"
    ];

    fallback-filter = {
      geoip = true;
      geoip-code = "CN";
      ipcidr = [ "240.0.0.0/4" "0.0.0.0/32" ];
    };

    use-hosts = true;
  };

  proxies = [
    {
      name = "azv6test";
      type = "ss";
      server = config.sops.placeholder.dui_ipv6;
      port = ports.ss1;
      cipher = "chacha20-ietf-poly1305";
      password = config.sops.placeholder.sspass;
      udp = true;
    }
    {
      name = "sswebsoc";
      type = "ss";
      server = "${fqdn.edg}";
      port = 443;
      cipher = "chacha20-ietf-poly1305";
      password = config.sops.placeholder.sspass;
      plugin = "v2ray-plugin";
      plugin-opts = {
        mode = "websocket";
        tls = true;
        host = "${fqdn.edg}";
        path = "${path.ss2}";
      };
    }
  ];

  proxy-providers = {
    london = {
      type = "http";
      url = config.sops.placeholder.clash-provider-london;
      interval = 3600;
      path = "london.yaml";
      health-check = {
        enable = true;
        interval = 600;
        url = "http://www.gstatic.com/generate_204";
      };
    };

    mumbai = {
      type = "http";
      url = config.sops.placeholder.clash-provider-mumbai;
      interval = 3600;
      path = "mumbai.yaml";
      health-check = {
        enable = true;
        interval = 600;
        url = "http://www.gstatic.com/generate_204";
      };
    };
  };

  proxy-groups =
    let
      custom-pxs = (map (x: (toString x.name)) proxies);
      providers = builtins.attrNames proxy-providers;
    in
    [
      {
        name = "select";
        type = "select";
        use = providers;
        proxies = custom-pxs ++ [
          "auto"
          "fallback"
          "DIRECT"
        ];
      }
      {
        name = "auto";
        type = "url-test";
        use = providers;
        proxies = custom-pxs;
        interval = 86400;
        url = "http://www.gstatic.com/generate_204";
      }
      {
        name = "fallback";
        type = "fallback";
        use = providers;
        proxies = custom-pxs;
        interval = 7200;
        url = "http://www.gstatic.com/generate_204";
      }
    ];

  rules = [
    "DOMAIN-SUFFIX,apps.apple.com,DIRECT"
    "DOMAIN-SUFFIX,itunes.apple.com,DIRECT"
    "DOMAIN-SUFFIX,blobstore.apple.com,DIRECT"
    "DOMAIN-SUFFIX,music.apple.com,DIRECT"
    "DOMAIN-SUFFIX,icloud.com,DIRECT"
    "DOMAIN-SUFFIX,icloud-content.com,DIRECT"
    "DOMAIN-SUFFIX,me.com,DIRECT"
    "DOMAIN-SUFFIX,mzstatic.com,DIRECT"
    "DOMAIN-SUFFIX,akadns.net,DIRECT"
    "DOMAIN-SUFFIX,aaplimg.com,DIRECT"
    "DOMAIN-SUFFIX,cdn-apple.com,DIRECT"
    "DOMAIN-SUFFIX,apple.com,DIRECT"
    "DOMAIN-SUFFIX,apple-cloudkit.com,DIRECT"
    "DOMAIN-SUFFIX,services.googleapis.cn,select"
    "DOMAIN-SUFFIX,cn,DIRECT"
    "DOMAIN-KEYWORD,-cn,DIRECT"
    "DOMAIN-SUFFIX,126.com,DIRECT"
    "DOMAIN-SUFFIX,126.net,DIRECT"
    "DOMAIN-SUFFIX,127.net,DIRECT"
    "DOMAIN-SUFFIX,163.com,DIRECT"
    "DOMAIN-SUFFIX,360buyimg.com,DIRECT"
    "DOMAIN-SUFFIX,36kr.com,DIRECT"
    "DOMAIN-SUFFIX,acfun.tv,DIRECT"
    "DOMAIN-SUFFIX,air-matters.com,DIRECT"
    "DOMAIN-SUFFIX,aixifan.com,DIRECT"
    "DOMAIN-SUFFIX,akamaized.net,DIRECT"
    "DOMAIN-KEYWORD,alicdn,DIRECT"
    "DOMAIN-KEYWORD,alipay,DIRECT"
    "DOMAIN-KEYWORD,taobao,DIRECT"
    "DOMAIN-SUFFIX,amap.com,DIRECT"
    "DOMAIN-SUFFIX,autonavi.com,DIRECT"
    "DOMAIN-KEYWORD,baidu,DIRECT"
    "DOMAIN-SUFFIX,bdimg.com,DIRECT"
    "DOMAIN-SUFFIX,bdstatic.com,DIRECT"
    "DOMAIN-SUFFIX,bilibili.com,DIRECT"
    "DOMAIN-SUFFIX,caiyunapp.com,DIRECT"
    "DOMAIN-SUFFIX,clouddn.com,DIRECT"
    "DOMAIN-SUFFIX,cnbeta.com,DIRECT"
    "DOMAIN-SUFFIX,cnbetacdn.com,DIRECT"
    "DOMAIN-SUFFIX,cootekservice.com,DIRECT"
    "DOMAIN-SUFFIX,csdn.net,DIRECT"
    "DOMAIN-SUFFIX,ctrip.com,DIRECT"
    "DOMAIN-SUFFIX,dgtle.com,DIRECT"
    "DOMAIN-SUFFIX,dianping.com,DIRECT"
    "DOMAIN-SUFFIX,douban.com,DIRECT"
    "DOMAIN-SUFFIX,doubanio.com,DIRECT"
    "DOMAIN-SUFFIX,duokan.com,DIRECT"
    "DOMAIN-SUFFIX,easou.com,DIRECT"
    "DOMAIN-SUFFIX,ele.me,DIRECT"
    "DOMAIN-SUFFIX,feng.com,DIRECT"
    "DOMAIN-SUFFIX,fir.im,DIRECT"
    "DOMAIN-SUFFIX,frdic.com,DIRECT"
    "DOMAIN-SUFFIX,g-cores.com,DIRECT"
    "DOMAIN-SUFFIX,godic.net,DIRECT"
    "DOMAIN-SUFFIX,gtimg.com,DIRECT"
    "DOMAIN,cdn.hockeyapp.net,DIRECT"
    "DOMAIN-SUFFIX,hongxiu.com,DIRECT"
    "DOMAIN-SUFFIX,hxcdn.net,DIRECT"
    "DOMAIN-SUFFIX,iciba.com,DIRECT"
    "DOMAIN-SUFFIX,ifeng.com,DIRECT"
    "DOMAIN-SUFFIX,ifengimg.com,DIRECT"
    "DOMAIN-SUFFIX,ipip.net,DIRECT"
    "DOMAIN-SUFFIX,iqiyi.com,DIRECT"
    "DOMAIN-SUFFIX,jd.com,DIRECT"
    "DOMAIN-SUFFIX,jianshu.com,DIRECT"
    "DOMAIN-SUFFIX,knewone.com,DIRECT"
    "DOMAIN-SUFFIX,le.com,DIRECT"
    "DOMAIN-SUFFIX,lecloud.com,DIRECT"
    "DOMAIN-SUFFIX,lemicp.com,DIRECT"
    "DOMAIN-SUFFIX,licdn.com,select"
    "DOMAIN-SUFFIX,linkedin.com,select"
    "DOMAIN-SUFFIX,luoo.net,DIRECT"
    "DOMAIN-SUFFIX,meituan.com,DIRECT"
    "DOMAIN-SUFFIX,meituan.net,DIRECT"
    "DOMAIN-SUFFIX,mi.com,DIRECT"
    "DOMAIN-SUFFIX,miaopai.com,DIRECT"
    "DOMAIN-SUFFIX,microsoft.com,DIRECT"
    "DOMAIN-SUFFIX,microsoftonline.com,DIRECT"
    "DOMAIN-SUFFIX,miui.com,DIRECT"
    "DOMAIN-SUFFIX,miwifi.com,DIRECT"
    "DOMAIN-SUFFIX,mob.com,DIRECT"
    "DOMAIN-SUFFIX,netease.com,DIRECT"
    "DOMAIN-SUFFIX,office.com,DIRECT"
    "DOMAIN-SUFFIX,office365.com,DIRECT"
    "DOMAIN-KEYWORD,officecdn,DIRECT"
    "DOMAIN-SUFFIX,oschina.net,DIRECT"
    "DOMAIN-SUFFIX,ppsimg.com,DIRECT"
    "DOMAIN-SUFFIX,pstatp.com,DIRECT"
    "DOMAIN-SUFFIX,qcloud.com,DIRECT"
    "DOMAIN-SUFFIX,qdaily.com,DIRECT"
    "DOMAIN-SUFFIX,qdmm.com,DIRECT"
    "DOMAIN-SUFFIX,qhimg.com,DIRECT"
    "DOMAIN-SUFFIX,qhres.com,DIRECT"
    "DOMAIN-SUFFIX,qidian.com,DIRECT"
    "DOMAIN-SUFFIX,qihucdn.com,DIRECT"
    "DOMAIN-SUFFIX,qiniu.com,DIRECT"
    "DOMAIN-SUFFIX,qiniucdn.com,DIRECT"
    "DOMAIN-SUFFIX,qiyipic.com,DIRECT"
    "DOMAIN-SUFFIX,qq.com,DIRECT"
    "DOMAIN-SUFFIX,qqurl.com,DIRECT"
    "DOMAIN-SUFFIX,rarbg.to,DIRECT"
    "DOMAIN-SUFFIX,ruguoapp.com,DIRECT"
    "DOMAIN-SUFFIX,segmentfault.com,DIRECT"
    "DOMAIN-SUFFIX,sinaapp.com,DIRECT"
    "DOMAIN-SUFFIX,smzdm.com,DIRECT"
    "DOMAIN-SUFFIX,snapdrop.net,DIRECT"
    "DOMAIN-SUFFIX,sogou.com,DIRECT"
    "DOMAIN-SUFFIX,sogoucdn.com,DIRECT"
    "DOMAIN-SUFFIX,sohu.com,DIRECT"
    "DOMAIN-SUFFIX,soku.com,DIRECT"
    "DOMAIN-SUFFIX,speedtest.net,DIRECT"
    "DOMAIN-SUFFIX,sspai.com,DIRECT"
    "DOMAIN-SUFFIX,suning.com,DIRECT"
    "DOMAIN-SUFFIX,taobao.com,DIRECT"
    "DOMAIN-SUFFIX,tencent.com,DIRECT"
    "DOMAIN-SUFFIX,tenpay.com,DIRECT"
    "DOMAIN-SUFFIX,tianyancha.com,DIRECT"
    "DOMAIN-SUFFIX,tmall.com,DIRECT"
    "DOMAIN-SUFFIX,tudou.com,DIRECT"
    "DOMAIN-SUFFIX,umetrip.com,DIRECT"
    "DOMAIN-SUFFIX,upaiyun.com,DIRECT"
    "DOMAIN-SUFFIX,upyun.com,DIRECT"
    "DOMAIN-SUFFIX,veryzhun.com,DIRECT"
    "DOMAIN-SUFFIX,weather.com,DIRECT"
    "DOMAIN-SUFFIX,weibo.com,DIRECT"
    "DOMAIN-SUFFIX,xiami.com,DIRECT"
    "DOMAIN-SUFFIX,xiami.net,DIRECT"
    "DOMAIN-SUFFIX,xiaomicp.com,DIRECT"
    "DOMAIN-SUFFIX,ximalaya.com,DIRECT"
    "DOMAIN-SUFFIX,xmcdn.com,DIRECT"
    "DOMAIN-SUFFIX,xunlei.com,DIRECT"
    "DOMAIN-SUFFIX,yhd.com,DIRECT"
    "DOMAIN-SUFFIX,yihaodianimg.com,DIRECT"
    "DOMAIN-SUFFIX,yinxiang.com,DIRECT"
    "DOMAIN-SUFFIX,ykimg.com,DIRECT"
    "DOMAIN-SUFFIX,youdao.com,DIRECT"
    "DOMAIN-SUFFIX,youku.com,DIRECT"
    "DOMAIN-SUFFIX,zealer.com,DIRECT"
    "DOMAIN-SUFFIX,zhihu.com,DIRECT"
    "DOMAIN-SUFFIX,zhimg.com,DIRECT"
    "DOMAIN-SUFFIX,zimuzu.tv,DIRECT"
    "DOMAIN-SUFFIX,zoho.com,DIRECT"
    "DOMAIN-KEYWORD,amazon,select"
    "DOMAIN-KEYWORD,google,select"
    "DOMAIN-KEYWORD,gmail,select"
    "DOMAIN-KEYWORD,youtube,select"
    "DOMAIN-KEYWORD,facebook,select"
    "DOMAIN-SUFFIX,fb.me,select"
    "DOMAIN-SUFFIX,fbcdn.net,select"
    "DOMAIN-KEYWORD,twitter,select"
    "DOMAIN-KEYWORD,instagram,select"
    "DOMAIN-KEYWORD,dropbox,select"
    "DOMAIN-SUFFIX,twimg.com,select"
    "DOMAIN-KEYWORD,blogspot,select"
    "DOMAIN-SUFFIX,youtu.be,select"
    "DOMAIN-KEYWORD,whatsapp,select"
    "DOMAIN-KEYWORD,admarvel,REJECT"
    "DOMAIN-KEYWORD,admaster,REJECT"
    "DOMAIN-KEYWORD,adsage,REJECT"
    "DOMAIN-KEYWORD,adsmogo,REJECT"
    "DOMAIN-KEYWORD,adsrvmedia,REJECT"
    "DOMAIN-KEYWORD,adwords,REJECT"
    "DOMAIN-KEYWORD,adservice,REJECT"
    "DOMAIN-KEYWORD,domob,REJECT"
    "DOMAIN-KEYWORD,duomeng,REJECT"
    "DOMAIN-KEYWORD,dwtrack,REJECT"
    "DOMAIN-KEYWORD,guanggao,REJECT"
    "DOMAIN-KEYWORD,lianmeng,REJECT"
    "DOMAIN-KEYWORD,omgmta,REJECT"
    "DOMAIN-KEYWORD,openx,REJECT"
    "DOMAIN-KEYWORD,partnerad,REJECT"
    "DOMAIN-KEYWORD,pingfore,REJECT"
    "DOMAIN-KEYWORD,supersonicads,REJECT"
    "DOMAIN-KEYWORD,tracking,REJECT"
    "DOMAIN-KEYWORD,uedas,REJECT"
    "DOMAIN-KEYWORD,umeng,REJECT"
    "DOMAIN-KEYWORD,usage,REJECT"
    "DOMAIN-KEYWORD,wlmonitor,REJECT"
    "DOMAIN-KEYWORD,zjtoolbar,REJECT"
    "DOMAIN-SUFFIX,9to5mac.com,select"
    "DOMAIN-SUFFIX,abpchina.org,select"
    "DOMAIN-SUFFIX,adblockplus.org,select"
    "DOMAIN-SUFFIX,adobe.com,select"
    "DOMAIN-SUFFIX,alfredapp.com,select"
    "DOMAIN-SUFFIX,amplitude.com,select"
    "DOMAIN-SUFFIX,ampproject.org,select"
    "DOMAIN-SUFFIX,android.com,select"
    "DOMAIN-SUFFIX,angularjs.org,select"
    "DOMAIN-SUFFIX,aolcdn.com,select"
    "DOMAIN-SUFFIX,apkpure.com,select"
    "DOMAIN-SUFFIX,appledaily.com,select"
    "DOMAIN-SUFFIX,appshopper.com,select"
    "DOMAIN-SUFFIX,appspot.com,select"
    "DOMAIN-SUFFIX,arcgis.com,select"
    "DOMAIN-SUFFIX,archive.org,select"
    "DOMAIN-SUFFIX,armorgames.com,select"
    "DOMAIN-SUFFIX,aspnetcdn.com,select"
    "DOMAIN-SUFFIX,att.com,select"
    "DOMAIN-SUFFIX,awsstatic.com,select"
    "DOMAIN-SUFFIX,azureedge.net,select"
    "DOMAIN-SUFFIX,azurewebsites.net,select"
    "DOMAIN-SUFFIX,bing.com,select"
    "DOMAIN-SUFFIX,bintray.com,select"
    "DOMAIN-SUFFIX,bit.com,select"
    "DOMAIN-SUFFIX,bit.ly,select"
    "DOMAIN-SUFFIX,bitbucket.org,select"
    "DOMAIN-SUFFIX,bjango.com,select"
    "DOMAIN-SUFFIX,bkrtx.com,select"
    "DOMAIN-SUFFIX,blog.com,select"
    "DOMAIN-SUFFIX,blogcdn.com,select"
    "DOMAIN-SUFFIX,blogger.com,select"
    "DOMAIN-SUFFIX,blogsmithmedia.com,select"
    "DOMAIN-SUFFIX,blogspot.com,select"
    "DOMAIN-SUFFIX,blogspot.hk,select"
    "DOMAIN-SUFFIX,bloomberg.com,select"
    "DOMAIN-SUFFIX,box.com,select"
    "DOMAIN-SUFFIX,box.net,select"
    "DOMAIN-SUFFIX,cachefly.net,select"
    "DOMAIN-SUFFIX,chromium.org,select"
    "DOMAIN-SUFFIX,cl.ly,select"
    "DOMAIN-SUFFIX,cloudflare.com,select"
    "DOMAIN-SUFFIX,cloudfront.net,select"
    "DOMAIN-SUFFIX,cloudmagic.com,select"
    "DOMAIN-SUFFIX,cmail19.com,select"
    "DOMAIN-SUFFIX,cnet.com,select"
    "DOMAIN-SUFFIX,cocoapods.org,select"
    "DOMAIN-SUFFIX,comodoca.com,select"
    "DOMAIN-SUFFIX,crashlytics.com,select"
    "DOMAIN-SUFFIX,culturedcode.com,select"
    "DOMAIN-SUFFIX,d.pr,select"
    "DOMAIN-SUFFIX,danilo.to,select"
    "DOMAIN-SUFFIX,dayone.me,select"
    "DOMAIN-SUFFIX,db.tt,select"
    "DOMAIN-SUFFIX,deskconnect.com,select"
    "DOMAIN-SUFFIX,disq.us,select"
    "DOMAIN-SUFFIX,disqus.com,select"
    "DOMAIN-SUFFIX,disquscdn.com,select"
    "DOMAIN-SUFFIX,dnsimple.com,select"
    "DOMAIN-SUFFIX,docker.com,select"
    "DOMAIN-SUFFIX,dribbble.com,select"
    "DOMAIN-SUFFIX,droplr.com,select"
    "DOMAIN-SUFFIX,duckduckgo.com,select"
    "DOMAIN-SUFFIX,dueapp.com,select"
    "DOMAIN-SUFFIX,dytt8.net,select"
    "DOMAIN-SUFFIX,edgecastcdn.net,select"
    "DOMAIN-SUFFIX,edgekey.net,select"
    "DOMAIN-SUFFIX,edgesuite.net,select"
    "DOMAIN-SUFFIX,engadget.com,select"
    "DOMAIN-SUFFIX,entrust.net,select"
    "DOMAIN-SUFFIX,eurekavpt.com,select"
    "DOMAIN-SUFFIX,evernote.com,select"
    "DOMAIN-SUFFIX,fabric.io,select"
    "DOMAIN-SUFFIX,fast.com,select"
    "DOMAIN-SUFFIX,fastly.net,select"
    "DOMAIN-SUFFIX,fc2.com,select"
    "DOMAIN-SUFFIX,feedburner.com,select"
    "DOMAIN-SUFFIX,feedly.com,select"
    "DOMAIN-SUFFIX,feedsportal.com,select"
    "DOMAIN-SUFFIX,fiftythree.com,select"
    "DOMAIN-SUFFIX,firebaseio.com,select"
    "DOMAIN-SUFFIX,flexibits.com,select"
    "DOMAIN-SUFFIX,flickr.com,select"
    "DOMAIN-SUFFIX,flipboard.com,select"
    "DOMAIN-SUFFIX,g.co,select"
    "DOMAIN-SUFFIX,gabia.net,select"
    "DOMAIN-SUFFIX,geni.us,select"
    "DOMAIN-SUFFIX,gfx.ms,select"
    "DOMAIN-SUFFIX,ggpht.com,select"
    "DOMAIN-SUFFIX,ghostnoteapp.com,select"
    "DOMAIN-SUFFIX,git.io,select"
    "DOMAIN-KEYWORD,github,select"
    "DOMAIN-SUFFIX,globalsign.com,select"
    "DOMAIN-SUFFIX,gmodules.com,select"
    "DOMAIN-SUFFIX,godaddy.com,select"
    "DOMAIN-SUFFIX,golang.org,select"
    "DOMAIN-SUFFIX,gongm.in,select"
    "DOMAIN-SUFFIX,goo.gl,select"
    "DOMAIN-SUFFIX,goodreaders.com,select"
    "DOMAIN-SUFFIX,goodreads.com,select"
    "DOMAIN-SUFFIX,gravatar.com,select"
    "DOMAIN-SUFFIX,gstatic.com,select"
    "DOMAIN-SUFFIX,gvt0.com,select"
    "DOMAIN-SUFFIX,hockeyapp.net,select"
    "DOMAIN-SUFFIX,hotmail.com,select"
    "DOMAIN-SUFFIX,icons8.com,select"
    "DOMAIN-SUFFIX,ifixit.com,select"
    "DOMAIN-SUFFIX,ift.tt,select"
    "DOMAIN-SUFFIX,ifttt.com,select"
    "DOMAIN-SUFFIX,iherb.com,select"
    "DOMAIN-SUFFIX,imageshack.us,select"
    "DOMAIN-SUFFIX,img.ly,select"
    "DOMAIN-SUFFIX,imgur.com,select"
    "DOMAIN-SUFFIX,imore.com,select"
    "DOMAIN-SUFFIX,instapaper.com,select"
    "DOMAIN-SUFFIX,ipn.li,select"
    "DOMAIN-SUFFIX,is.gd,select"
    "DOMAIN-SUFFIX,issuu.com,select"
    "DOMAIN-SUFFIX,itgonglun.com,select"
    "DOMAIN-SUFFIX,itun.es,select"
    "DOMAIN-SUFFIX,ixquick.com,select"
    "DOMAIN-SUFFIX,j.mp,select"
    "DOMAIN-SUFFIX,js.revsci.net,select"
    "DOMAIN-SUFFIX,jshint.com,select"
    "DOMAIN-SUFFIX,jtvnw.net,select"
    "DOMAIN-SUFFIX,justgetflux.com,select"
    "DOMAIN-SUFFIX,kat.cr,select"
    "DOMAIN-SUFFIX,klip.me,select"
    "DOMAIN-SUFFIX,libsyn.com,select"
    "DOMAIN-SUFFIX,linode.com,select"
    "DOMAIN-SUFFIX,lithium.com,select"
    "DOMAIN-SUFFIX,littlehj.com,select"
    "DOMAIN-SUFFIX,live.com,select"
    "DOMAIN-SUFFIX,live.net,select"
    "DOMAIN-SUFFIX,livefilestore.com,select"
    "DOMAIN-SUFFIX,llnwd.net,select"
    "DOMAIN-SUFFIX,macid.co,select"
    "DOMAIN-SUFFIX,macromedia.com,select"
    "DOMAIN-SUFFIX,macrumors.com,select"
    "DOMAIN-SUFFIX,mashable.com,select"
    "DOMAIN-SUFFIX,mathjax.org,select"
    "DOMAIN-SUFFIX,medium.com,select"
    "DOMAIN-SUFFIX,mega.co.nz,select"
    "DOMAIN-SUFFIX,mega.nz,select"
    "DOMAIN-SUFFIX,megaupload.com,select"
    "DOMAIN-SUFFIX,microsofttranslator.com,select"
    "DOMAIN-SUFFIX,mindnode.com,select"
    "DOMAIN-SUFFIX,mobile01.com,select"
    "DOMAIN-SUFFIX,modmyi.com,select"
    "DOMAIN-SUFFIX,msedge.net,select"
    "DOMAIN-SUFFIX,myfontastic.com,select"
    "DOMAIN-SUFFIX,name.com,select"
    "DOMAIN-SUFFIX,nextmedia.com,select"
    "DOMAIN-SUFFIX,nsstatic.net,select"
    "DOMAIN-SUFFIX,nssurge.com,select"
    "DOMAIN-SUFFIX,nyt.com,select"
    "DOMAIN-SUFFIX,nytimes.com,select"
    "DOMAIN-SUFFIX,omnigroup.com,select"
    "DOMAIN-SUFFIX,onedrive.com,select"
    "DOMAIN-SUFFIX,onenote.com,select"
    "DOMAIN-SUFFIX,ooyala.com,select"
    "DOMAIN-SUFFIX,openvpn.net,select"
    "DOMAIN-SUFFIX,openwrt.org,select"
    "DOMAIN-SUFFIX,orkut.com,select"
    "DOMAIN-SUFFIX,osxdaily.com,select"
    "DOMAIN-SUFFIX,outlook.com,select"
    "DOMAIN-SUFFIX,ow.ly,select"
    "DOMAIN-SUFFIX,paddleapi.com,select"
    "DOMAIN-SUFFIX,parallels.com,select"
    "DOMAIN-SUFFIX,parse.com,select"
    "DOMAIN-SUFFIX,pdfexpert.com,select"
    "DOMAIN-SUFFIX,periscope.tv,select"
    "DOMAIN-SUFFIX,pinboard.in,select"
    "DOMAIN-SUFFIX,pinterest.com,select"
    "DOMAIN-SUFFIX,pixelmator.com,select"
    "DOMAIN-SUFFIX,pixiv.net,select"
    "DOMAIN-SUFFIX,playpcesor.com,select"
    "DOMAIN-SUFFIX,playstation.com,select"
    "DOMAIN-SUFFIX,playstation.com.hk,select"
    "DOMAIN-SUFFIX,playstation.net,select"
    "DOMAIN-SUFFIX,playstationnetwork.com,select"
    "DOMAIN-SUFFIX,pushwoosh.com,select"
    "DOMAIN-SUFFIX,rime.im,select"
    "DOMAIN-SUFFIX,servebom.com,select"
    "DOMAIN-SUFFIX,sfx.ms,select"
    "DOMAIN-SUFFIX,shadowsocks.org,select"
    "DOMAIN-SUFFIX,sharethis.com,select"
    "DOMAIN-SUFFIX,shazam.com,select"
    "DOMAIN-SUFFIX,skype.com,select"
    "DOMAIN-SUFFIX,smartdnsauto.com,select"
    "DOMAIN-SUFFIX,smartmailcloud.com,select"
    "DOMAIN-SUFFIX,sndcdn.com,select"
    "DOMAIN-SUFFIX,sony.com,select"
    "DOMAIN-SUFFIX,soundcloud.com,select"
    "DOMAIN-SUFFIX,sourceforge.net,select"
    "DOMAIN-SUFFIX,spotify.com,select"
    "DOMAIN-SUFFIX,squarespace.com,select"
    "DOMAIN-SUFFIX,sstatic.net,select"
    "DOMAIN-SUFFIX,st.luluku.pw,select"
    "DOMAIN-SUFFIX,stackoverflow.com,select"
    "DOMAIN-SUFFIX,startpage.com,select"
    "DOMAIN-SUFFIX,staticflickr.com,select"
    "DOMAIN-SUFFIX,steamcommunity.com,select"
    "DOMAIN-SUFFIX,symauth.com,select"
    "DOMAIN-SUFFIX,symcb.com,select"
    "DOMAIN-SUFFIX,symcd.com,select"
    "DOMAIN-SUFFIX,tapbots.com,select"
    "DOMAIN-SUFFIX,tapbots.net,select"
    "DOMAIN-SUFFIX,tdesktop.com,select"
    "DOMAIN-SUFFIX,techcrunch.com,select"
    "DOMAIN-SUFFIX,techsmith.com,select"
    "DOMAIN-SUFFIX,thepiratebay.org,select"
    "DOMAIN-SUFFIX,theverge.com,select"
    "DOMAIN-SUFFIX,time.com,select"
    "DOMAIN-SUFFIX,timeinc.net,select"
    "DOMAIN-SUFFIX,tiny.cc,select"
    "DOMAIN-SUFFIX,tinypic.com,select"
    "DOMAIN-SUFFIX,tmblr.co,select"
    "DOMAIN-SUFFIX,todoist.com,select"
    "DOMAIN-SUFFIX,trello.com,select"
    "DOMAIN-SUFFIX,trustasiassl.com,select"
    "DOMAIN-SUFFIX,tumblr.co,select"
    "DOMAIN-SUFFIX,tumblr.com,select"
    "DOMAIN-SUFFIX,tweetdeck.com,select"
    "DOMAIN-SUFFIX,tweetmarker.net,select"
    "DOMAIN-SUFFIX,twitch.tv,select"
    "DOMAIN-SUFFIX,txmblr.com,select"
    "DOMAIN-SUFFIX,typekit.net,select"
    "DOMAIN-SUFFIX,ubertags.com,select"
    "DOMAIN-SUFFIX,ublock.org,select"
    "DOMAIN-SUFFIX,ubnt.com,select"
    "DOMAIN-SUFFIX,ulyssesapp.com,select"
    "DOMAIN-SUFFIX,urchin.com,select"
    "DOMAIN-SUFFIX,usertrust.com,select"
    "DOMAIN-SUFFIX,v.gd,select"
    "DOMAIN-SUFFIX,v2ex.com,select"
    "DOMAIN-SUFFIX,vimeo.com,select"
    "DOMAIN-SUFFIX,vimeocdn.com,select"
    "DOMAIN-SUFFIX,vine.co,select"
    "DOMAIN-SUFFIX,vivaldi.com,select"
    "DOMAIN-SUFFIX,vox-cdn.com,select"
    "DOMAIN-SUFFIX,vsco.co,select"
    "DOMAIN-SUFFIX,vultr.com,select"
    "DOMAIN-SUFFIX,w.org,select"
    "DOMAIN-SUFFIX,w3schools.com,select"
    "DOMAIN-SUFFIX,webtype.com,select"
    "DOMAIN-SUFFIX,wikiwand.com,select"
    "DOMAIN-SUFFIX,wikileaks.org,select"
    "DOMAIN-SUFFIX,wikimedia.org,select"
    "DOMAIN-SUFFIX,wikipedia.com,select"
    "DOMAIN-SUFFIX,wikipedia.org,select"
    "DOMAIN-SUFFIX,windows.com,select"
    "DOMAIN-SUFFIX,windows.net,select"
    "DOMAIN-SUFFIX,wire.com,select"
    "DOMAIN-SUFFIX,wordpress.com,select"
    "DOMAIN-SUFFIX,workflowy.com,select"
    "DOMAIN-SUFFIX,wp.com,select"
    "DOMAIN-SUFFIX,wsj.com,select"
    "DOMAIN-SUFFIX,wsj.net,select"
    "DOMAIN-SUFFIX,xda-developers.com,select"
    "DOMAIN-SUFFIX,xeeno.com,select"
    "DOMAIN-SUFFIX,xiti.com,select"
    "DOMAIN-SUFFIX,yahoo.com,select"
    "DOMAIN-SUFFIX,yimg.com,select"
    "DOMAIN-SUFFIX,ying.com,select"
    "DOMAIN-SUFFIX,yoyo.org,select"
    "DOMAIN-SUFFIX,ytimg.com,select"
    "DOMAIN-SUFFIX,telegra.ph,select"
    "DOMAIN-SUFFIX,telegram.org,select"
    "IP-CIDR,91.108.56.0/22,select"
    "IP-CIDR,91.108.4.0/22,select"
    "IP-CIDR,91.108.8.0/22,select"
    "IP-CIDR,109.239.140.0/24,select"
    "IP-CIDR,149.154.160.0/20,select"
    "IP-CIDR,149.154.164.0/22,select"
    "DOMAIN-SUFFIX,local,DIRECT"
    "IP-CIDR,127.0.0.0/8,DIRECT"
    "IP-CIDR,172.16.0.0/12,DIRECT"
    "IP-CIDR,192.168.0.0/16,DIRECT"
    "IP-CIDR,10.0.0.0/8,DIRECT"
    "IP-CIDR,17.0.0.0/8,DIRECT"
    "IP-CIDR,100.64.0.0/10,DIRECT"
    "GEOIP,CN,DIRECT"
    "MATCH,select"
  ];
}
