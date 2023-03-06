(async () => {
    try {
        const app = require('express')();
        const {Noco} = require("nocodb");
        const httpServer = app.listen(process.env.PORT || 8080, process.env.HOST || "0.0.0.0");
        app.use(await Noco.init({}, httpServer, app));
    } catch(e) {
        console.log(e)
        process.exit(1)
    }
})()
