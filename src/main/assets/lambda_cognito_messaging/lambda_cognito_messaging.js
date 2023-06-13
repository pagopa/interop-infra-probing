const _ = require('lodash.template');
const fs = require('fs')
exports.handler = async (event) => {
    if (event.triggerSource === "CustomMessage_ForgotPassword") {
      const message = _(fs.readFileSync('email_templates/forgotPasswordMailTemplate.html'), {fe_url: process.env.FE_URL, reset_password_route: process.env.RESET_PASSOWORD_ROUTE, reset_code: event.request.codeParameter,username:event.request.usernameParameter});
      event.response.emailMessage = message;
      event.response.emailSubject = "Ripristino Password";
    } else   if (event.triggerSource === "CustomMessage_AdminCreateUser") {
      //const message = _(fs.readFileSync('email_templates/forgotPasswordMailTemplate.html'), {fe_url: process.env.FE_URL, reset_password_route: process.env.LOGIN_ROUTE});;
      event.response.emailMessage = `Il messaggio è ${event.request.codeParameter}`;
      event.response.emailSubject = "Nuova utenza attiva";
    }
    return event;
};  