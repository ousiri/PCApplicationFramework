var projConf = {
    "subPath": "",
    "cdnRoot": {
        "js": "",
        "css": "",
        "img": ""
    },
    "htdocs": ""
};

fis.config.set('project.exclude', /((?:^|\/)_.*\.(?:scss))|(.*\.inline\.html)|(readme\.md)|(fis\-conf)|(layout\.jade)|(base\.jade)/i);

fis.config.merge({
    modules: {
        parser: {
            less: 'less',
            coffee: 'coffee-script',
            jade: 'jade',
            tpl: 'rabbitpre-tpl'
        },
        postprocessor: {
            js: "jswrapper, require-async",
            coffee: "jswrapper, require-async",
            html: "require-async",
            less: 'pleeease',
            css: 'pleeease',
            tpl: {
                js: 'jswrapper, require-async'
            }
        },
        prepackager: ['csswrapper', 'ousiri-async-build'],
        spriter: 'csssprites'
    },
    settings: {
        postprocessor: {
            jswrapper: {
                type: 'amd'
            }
        },
        prepackager: {
            'ousiri-async-build': {
                libs: [],
                ignores: [],
                cssInline: false,
                useInlineMap: true,
                cssPack: true
            }
        },
        spriter: {
            csssprites: {
                margin: 10,
                layout: 'matrix'
            }
        }
    },
    roadmap: {
        ext: {
            less: 'css',
            coffee: 'js',
            jade: 'html',
            tpl: 'tpl.js'
        },
        domain: {
            "**.js": projConf.cdnRoot.js + '/' + projConf.subPath,
            "**.coffee": projConf.cdnRoot.js + '/' + projConf.subPath,
            "**.css": projConf.cdnRoot.css + '/' + projConf.subPath,
            "**.less": projConf.cdnRoot.css + '/' + projConf.subPath,
            "**.png": projConf.cdnRoot.img + '/' + projConf.subPath,
            "**.gif": projConf.cdnRoot.img + '/' + projConf.subPath,
            "**.jpg": projConf.cdnRoot.img + '/' + projConf.subPath,
            "**.html": projConf.htdocs + '/' + projConf.subPath,
            "**.mp3": projConf.cdnRoot.img + '/' + projConf.subPath,
            "**.ico": projConf.cdnRoot.img + '/' + projConf.subPath,
            "**.tpl": projConf.cdnRoot.js + '/' + projConf.subPath,
            "**.tpl.js": projConf.cdnRoot.js + '/' + projConf.subPath
        },
        path: [
            {
                reg: '**/*.ico',
                useHash: true
            },
            {
                reg: projConf.jsNoWrap || '**/mod.js',
                isMod: false
            },
            {
                reg: /inline\.(js|coffee)$/i,
                isMod: false
            },
            {
                reg: /^\/static\/js\/(.*\.(js|coffee))$/i,
                isMod: false
            },
            {
                reg: /^\/widget\/(.*)\.async\.(css|scss|less)$/i,
                isMod: true,
                id: '$1.async.$2',
                extras: {
                    wrapcss: true
                }
            },
            {
                reg: /^\/(.*)\.async\.(css|scss|less)$/i,
                isMod: true,
                id: '$1.async.$2',
                extras: {
                    wrapcss: true
                }
            },
            // 页面级 js
            // 设置 page/**.js 为 isMod 可以自动包装成 amd
            {
                reg: /^\/page\/((?:[^\/]+\/)*)([^\/]+)\/\2\.(js|coffee)$/i,
                isMod: true,
                id: 'page/$1$2'
            },
            // 去掉JS后缀
            {
                reg: /^\/page\/(.*)\.(js|coffee)$/i,
                isMod: true,
                id: 'page/$1'
            },
            // widget 级 js
            {
                reg: /^\/widget\/((?:[^\/]+\/)*)([^\/]+)\/\2\.(js|coffee)$/i,
                isMod: true,
                id: '$1$2'
            },
            {
                reg: /^\/widget\/(.*)\.(js|coffee)$/i,
                isMod: true,
                id: '$1'
            },
            {
                reg: '**.html',
                useDomain: true
            },
            {
                reg: /^\/widget\/(.*\.(?:jade))$/i,
                isMod: true,
                url: '/widget/$1',
                release: 'widget/$1'
            },
            {
                reg: /^\/page\/((?:[^\/]+\/)*)([^\/]+)\/\2\.(jade)$/i,
                isMod: true,
                release: '/$2',
                useDomain: true,
                extras: {
                    isPage: true
                }
            },
            {
                reg: /^\/page\/(.+\.(?:jade))$/i,
                isMod: true,
                url: '/page/$1',
                release: 'page/$1',
                useDomain: true,
                extras: {
                    isPage: true
                }
            },
            {
                reg: /^\/page\/(.*)\.(tpl)$/i,
                isMod: true,
                useDomain: true,
                isJsLike: true,
                id: 'page/$1.$2'
            },
            {
                reg: /^\/widget\/(.*)\.(tpl)$/i,
                isMod: true,
                useDomain: true,
                isJsLike: true,
                id: '$1.$2'
            }
        ]
    },
    pack: {},
    deploy: {
        dist: {
            to: '../dist'
        }
    }
});

