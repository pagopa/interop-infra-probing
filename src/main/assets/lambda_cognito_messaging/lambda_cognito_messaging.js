const handler = async (event) => {
    if (event.triggerSource === "CustomMessage_ForgotPassword") {
      const message = `Your code is ${event.request.codeParameter}.`;
      event.response.emailMessage = message;
      event.response.emailSubject = "Reset Password";
    }
    return event;
  };
  
  export { handler };
  