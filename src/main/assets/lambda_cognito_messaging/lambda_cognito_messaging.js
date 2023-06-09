const _ = require('lodash.template');
const fs = require('fs')
exports.handler = async (event) => {
    if (event.triggerSource === "CustomMessage_ForgotPassword") {
      const message = _(fs.readFileSync('email_templates/resetPassword.html'), {fe_url: process.env.FE_URL, reset_password_route: process.env.RESET_PASSOWORD_ROUTE, reset_code: event.request.codeParameter,username:event.request.usernameParameter});
      event.response.emailMessage = message;
      event.response.emailSubject = "Ripristino Password";
    } else   if (event.triggerSource === "CustomMessage_AdminCreateUser") {
      const message = `Welcome to the service. Your user name is ${event.request.usernameParameter}. Your temporary password is ${event.request.codeParameter}`;
      event.response.smsMessage = message;
      event.response.emailMessage = message;
      event.response.emailSubject = "Welcome to the service";
    }
    return event;
};  