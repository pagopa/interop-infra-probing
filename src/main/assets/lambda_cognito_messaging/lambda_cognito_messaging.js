exports.handler = async (event) => {
    if (event.triggerSource === "CustomMessage_ForgotPassword") {
      const message = `Your code is ${event.request.codeParameter}.`;
      event.response.emailMessage = message;
      event.response.emailSubject = "Reset Password";
    } else   if (event.triggerSource === "CustomMessage_AdminCreateUser") {
      const message = `Welcome to the service. Your user name is ${event.request.usernameParameter}. Your temporary password is ${event.request.codeParameter}`;
      event.response.smsMessage = message;
      event.response.emailMessage = message;
      event.response.emailSubject = "Welcome to the service";
    }
    return event;
};  