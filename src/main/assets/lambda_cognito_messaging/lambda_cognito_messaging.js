exports.handler = async (event) => {

  var envInfo = (process.env.ENV === "prod") ? "" : ` - ${process.env.ENV}`;

  if (event.triggerSource === "CustomMessage_ForgotPassword") {
    const message = `<!DOCTYPE HTML PUBLIC "-//W3C//DTD XHTML 1.0 Transitional //EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office">
    <head>
    <!--[if gte mso 9]>
    <xml>
      <o:OfficeDocumentSettings>
        <o:AllowPNG/>
        <o:PixelsPerInch>96</o:PixelsPerInch>
      </o:OfficeDocumentSettings>
    </xml>
    <![endif]-->
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <meta name="x-apple-disable-message-reformatting">
      <link href='https://fonts.googleapis.com/css?family=Titillium Web' rel='stylesheet'>
      <!--[if !mso]><!--><meta http-equiv="X-UA-Compatible" content="IE=edge"><!--<![endif]-->
      <title></title>        
        <style type="text/css">
          @media only screen and (min-width: 652px) {
      .u-row {
        width: 632px !important;
      }
      .u-row .u-col {
        vertical-align: top;
      }
    
      .u-row .u-col-100 {
        width: 632px !important;
      }
    
    }
    
    @media (max-width: 652px) {
      .u-row-container {
        max-width: 100% !important;
        padding-left: 0px !important;
        padding-right: 0px !important;
      }
      .u-row .u-col {
        min-width: 320px !important;
        max-width: 100% !important;
        display: block !important;
      }
      .u-row {
        width: 100% !important;
      }
      .u-col {
        width: 100% !important;
      }
      .u-col > div {
        margin: 0 auto;
      }
    }
    body {
      margin: 0;
      padding: 0;
      font-family: 'Titillium Web';
      color: #17324d";
      background-color: #ffffff;
      font-size: 18px;
      line-height: 28px;
      text-align: left;
      font-weight: 400;
    }
    
    table,
    tr,
    td {
      vertical-align: top;
      border-collapse: collapse;
    }
    
    p {
      margin: 0;
    }
    
    .ie-container table,
    .mso-container table {
      table-layout: fixed;
    }
    
    * {
      line-height: inherit;
    }
    
    a[x-apple-data-detectors='true'] {
      color: inherit !important;
      text-decoration: none !important;
    }
    
    .css-zr5gjd {
        display: inline-block;
        user-select: none;
        width: 100px;
      height:28px;
      margin-bottom: 10px;
      margin-top: 50px;
    }
    
    
    table, td { color: #17324d; } #u_body a { color: #0073e6; text-decoration: underline; }
        </style>
      
      
    
    </head>
    
    <body class="clean-body u_body" style="margin: 0;padding: 0;-webkit-text-size-adjust: 100%;">
      <!--[if IE]><div class="ie-container"><![endif]-->
      <!--[if mso]><div class="mso-container"><![endif]-->
    
      <table id="u_body" style="border-collapse: collapse;table-layout: fixed;border-spacing: 0;mso-table-lspace: 0pt;mso-table-rspace: 0pt;vertical-align: top;min-width: 320px;Margin: 0 auto;background-color: #ffffff;width:100%" cellpadding="0" cellspacing="0">
      <tbody>
      <tr style="vertical-align: top">
        <td style="word-break: break-word;border-collapse: collapse !important;vertical-align: top">
        <!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td align="center" style="background-color: #ffffff;"><![endif]-->
        
    
    <div class="u-row-container" style="padding: 0px;background-color: transparent">
      <div class="u-row" style="Margin: 0 auto;min-width: 320px;max-width: 632px;overflow-wrap: break-word;word-wrap: break-word;word-break: break-word;background-color: transparent;">
        <div style="border-collapse: collapse;display: table;width: 100%;height: 100%;background-color: transparent;">
          <!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding: 0px;background-color: transparent;" align="center"><table cellpadding="0" cellspacing="0" border="0" style="width:632px;"><tr style="background-color: transparent;"><![endif]-->
          
    <!--[if (mso)|(IE)]><td align="center" width="632" style="width: 632px;padding: 0px;border-top: 0px solid transparent;border-left: 0px solid transparent;border-right: 0px solid transparent;border-bottom: 0px solid transparent;" valign="top"><![endif]-->
    <div class="u-col u-col-100" style="max-width: 320px;min-width: 632px;display: table-cell;vertical-align: top;">
      <div style="height: 100%;width: 100% !important;">
      <!--[if (!mso)&(!IE)]><!--><div style="box-sizing: border-box; height: 100%; padding: 0px;border-top: 0px solid transparent;border-left: 0px solid transparent;border-right: 0px solid transparent;border-bottom: 0px solid transparent;"><!--<![endif]-->
      
    <table role="presentation" cellpadding="0" cellspacing="0" width="100%" border="0">
      <tbody>
        <tr>
          <td style="overflow-wrap:break-word;word-break:break-word;padding:10px;" align="left">
             <img class="css-zr5gjd" src="https://www.interop.pagopa.it/static/logo/pagopa.png" alt="logo PagoPa"/>
      <h1 style="margin-bottom: 10px; word-wrap: break-word; font-size: 32px; font-weight: 700; line-height:40px;"><strong>Ripristino password</strong></h1>      
          </td>
        </tr>
      </tbody>
    </table>
    
    <table role="presentation" cellpadding="0" cellspacing="0" width="100%" border="0">
      <tbody>
        <tr>
          <td style="overflow-wrap:break-word;word-break:break-word;padding:10px;" align="left">
            
      <div style=" word-wrap: break-word;">
        <p>Ciao,</p>
      </div>
    
          </td>
        </tr>
      </tbody>
    </table>
    
    <table  role="presentation" cellpadding="0" cellspacing="0" width="100%" border="0">
      <tbody>
        <tr>
          <td style="overflow-wrap:break-word;word-break:break-word;padding:10px;" align="left">
            
      <div style="word-wrap: break-word;">
        <p >è stato chiesto un ripristino della password per questa utenza sul</p>
    <p>portale di monitoraggio e-service di <strong>PDND Interoperabilità</strong>. <span style="color: #0073e6; line-height: 30.6px;"><a rel="noopener" href="${process.env.FE_URL}${process.env.RESET_PASSOWORD_ROUTE}#code=${event.request.codeParameter}&username=${event.request.userAttributes.email}" target="_blank" style="color: #0073e6;">Clicca qui</a></span></p>
    <p>per inserire la nuova password e completare la procedura.</p>
    <br />
    <p>Se hai problemi tecnici o domande in merito al funzionamento del</p>
    <p>portale di monitoraggio, scrivi a <span style="color: #0073e6; line-height: 30.6px;"><a rel="noopener" href="mailto:interop@assistenza.pagopa.it" target="_blank" style="color: #0073e6;">interop@assistenza.pagopa.it</a></span></p>
    <br />
    <p>A presto,</p>
    <p>Il team di PagoPA S.p.A.</p>
      </div>
    
          </td>
        </tr>
      </tbody>
    </table>
    
    <table role="presentation" cellpadding="0" cellspacing="0" width="100%" border="0">
      <tbody>
        <tr>
          <td style="overflow-wrap:break-word;word-break:break-word;padding:10px;" align="left">
            
      <table height="0px" align="left" border="0" cellpadding="0" cellspacing="0" width="542px" style="border-collapse: collapse;table-layout: fixed;border-spacing: 0;mso-table-lspace: 0pt;mso-table-rspace: 0pt;vertical-align: top;border-top: 1px solid #BBBBBB;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%">
        <tbody>
          <tr style="vertical-align: top">
            <td style="word-break: break-word;border-collapse: collapse !important;vertical-align: top;font-size: 0px;line-height: 0px;mso-line-height-rule: exactly;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%">
              <hr style="border: 1px #E3E7EB;">
            </td>
          </tr>
        </tbody>
      </table>
    
          </td>
        </tr>
      </tbody>
    </table>
    
    <table role="presentation" cellpadding="0" cellspacing="0" width="100%" border="0">
      <tbody>
        <tr>
          <td style="overflow-wrap:break-word;word-break:break-word;padding:10px;" align="left">
            
      <div style="font-size: 14px;word-wrap: break-word;">
        <p><span style="color: #ced4d9;"><span style="line-height: 20px;">Ricevi questo messaggio perché hai un’utenza attiva nell’Area Riservata dell’ent</span>e.</span></p>
      </div>
    
          </td>
        </tr>
      </tbody>
    </table>
    
      <!--[if (!mso)&(!IE)]><!--></div><!--<![endif]-->
      </div>
    </div>
    <!--[if (mso)|(IE)]></td><![endif]-->
          <!--[if (mso)|(IE)]></tr></table></td></tr></table><![endif]-->
        </div>
      </div>
    </div>
    
    
        <!--[if (mso)|(IE)]></td></tr></table><![endif]-->
        </td>
      </tr>
      </tbody>
      </table>
      <!--[if mso]></div><![endif]-->
      <!--[if IE]></div><![endif]-->
    </body      
    </html>
    `;
    event.response.emailMessage = message;
    event.response.emailSubject = "Ripristino Password" + envInfo;
  } else   if (event.triggerSource === "CustomMessage_AdminCreateUser") {
    const message = `<!DOCTYPE HTML PUBLIC "-//W3C//DTD XHTML 1.0 Transitional //EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office">
    <head>
    <!--[if gte mso 9]>
    <xml>
      <o:OfficeDocumentSettings>
        <o:AllowPNG/>
        <o:PixelsPerInch>96</o:PixelsPerInch>
      </o:OfficeDocumentSettings>
    </xml>
    <![endif]-->
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <meta name="x-apple-disable-message-reformatting">
      <link href='https://fonts.googleapis.com/css?family=Titillium Web' rel='stylesheet'>
      <!--[if !mso]><!--><meta http-equiv="X-UA-Compatible" content="IE=edge"><!--<![endif]-->
      <title></title>
      
        <style type="text/css">
          @media only screen and (min-width: 652px) {
      .u-row {
        width: 632px !important;
      }
      .u-row .u-col {
        vertical-align: top;
      }
    
      .u-row .u-col-100 {
        width: 632px !important;
      }
    
    }
    
    @media (max-width: 652px) {
      .u-row-container {
        max-width: 100% !important;
        padding-left: 0px !important;
        padding-right: 0px !important;
      }
      .u-row .u-col {
        min-width: 320px !important;
        max-width: 100% !important;
        display: block !important;
      }
      .u-row {
        width: 100% !important;
      }
      .u-col {
        width: 100% !important;
      }
      .u-col > div {
        margin: 0 auto;
      }
    }
    body {
      margin: 0;
      padding: 0;
      font-family: 'Titillium Web';
      color: #17324d";
      background-color: #ffffff;
      font-size: 18px;
      line-height: 28px;
      text-align: left;
      font-weight: 400;
    }
    
    table,
    tr,
    td {
      vertical-align: top;
      border-collapse: collapse;
    }
    
    p {
      margin: 0;
    }
    
    .ie-container table,
    .mso-container table {
      table-layout: fixed;
    }
    
    * {
      line-height: inherit;
    }
    
    a[x-apple-data-detectors='true'] {
      color: inherit !important;
      text-decoration: none !important;
    }
    
    .css-zr5gjd {
        display: inline-block;
        user-select: none;
        width: 100px;
      height:28px;
      margin-bottom: 10px;
      margin-top: 50px;
    }
    
    table, td { color: #17324d; } #u_body a { color: #0073e6; text-decoration: underline; }
        </style>
      
      
    
    </head>
    
    <body class="clean-body u_body" style="margin: 0;padding: 0;-webkit-text-size-adjust: 100%;">
      <!--[if IE]><div class="ie-container"><![endif]-->
      <!--[if mso]><div class="mso-container"><![endif]-->
    
      <table id="u_body" style="border-collapse: collapse;table-layout: fixed;border-spacing: 0;mso-table-lspace: 0pt;mso-table-rspace: 0pt;vertical-align: top;min-width: 320px;Margin: 0 auto;background-color: #ffffff;width:100%" cellpadding="0" cellspacing="0">
      <tbody>
      <tr style="vertical-align: top">
        <td style="word-break: break-word;border-collapse: collapse !important;vertical-align: top">
        <!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td align="center" style="background-color: #ffffff;"><![endif]-->
        
    
    <div class="u-row-container" style="padding: 0px;background-color: transparent">
      <div class="u-row" style="Margin: 0 auto;min-width: 320px;max-width: 632px;overflow-wrap: break-word;word-wrap: break-word;word-break: break-word;background-color: transparent;">
        <div style="border-collapse: collapse;display: table;width: 100%;height: 100%;background-color: transparent;">
          <!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding: 0px;background-color: transparent;" align="center"><table cellpadding="0" cellspacing="0" border="0" style="width:632px;"><tr style="background-color: transparent;"><![endif]-->
          
    <!--[if (mso)|(IE)]><td align="center" width="632" style="width: 632px;padding: 0px;border-top: 0px solid transparent;border-left: 0px solid transparent;border-right: 0px solid transparent;border-bottom: 0px solid transparent;" valign="top"><![endif]-->
    <div class="u-col u-col-100" style="max-width: 320px;min-width: 632px;display: table-cell;vertical-align: top;">
      <div style="height: 100%;width: 100% !important;">
      <!--[if (!mso)&(!IE)]><!--><div style="box-sizing: border-box; height: 100%; padding: 0px;border-top: 0px solid transparent;border-left: 0px solid transparent;border-right: 0px solid transparent;border-bottom: 0px solid transparent;"><!--<![endif]-->
      
    <table role="presentation" cellpadding="0" cellspacing="0" width="100%" border="0">
      <tbody>
        <tr>
          <td style="overflow-wrap:break-word;word-break:break-word;padding:10px;" align="left">
             <img class="css-zr5gjd" src="https://www.interop.pagopa.it/static/logo/pagopa.png" alt="logo PagoPa"/>
      <h1 style="margin-bottom: 10px; word-wrap: break-word; font-size: 32px; font-weight: 700; line-height:40px;"><strong>Nuova utenza attiva</strong></h1>
    
          </td>
        </tr>
      </tbody>
    </table>
    
    <table role="presentation" cellpadding="0" cellspacing="0" width="100%" border="0">
      <tbody>
        <tr>
          <td style="overflow-wrap:break-word;word-break:break-word;padding:10px;" align="left">
            
      <div style=" word-wrap: break-word;">
        <p>Ciao,</p>
      </div>
    
          </td>
        </tr>
      </tbody>
    </table>
    
    <table  role="presentation" cellpadding="0" cellspacing="0" width="100%" border="0">
      <tbody>
        <tr>
          <td style="overflow-wrap:break-word;word-break:break-word;padding:10px;" align="left">
            
      <div style="word-wrap: break-word;">
        <!-- ${event.request.codeParameter}${event.request.usernameParameter} -->
        <p >è stata creata una nuova utenza per te sul portale di monitoraggio e-</p>
    <p>-service di <strong>PDND Interoperabilità</strong>.  Per effettuare il primo accesso, vai</p>
    <p>alla <span style="color: #0073e6; line-height: 30.6px;"><a rel="noopener" href="${process.env.FE_URL}${process.env.LOGIN_ROUTE}" target="_blank" style="color: #0073e6;">pagina di login</a></span>, clicca su “Hai dimenticato la password? Clicca qui</p>
    <p>per ripristinarla”, e segui la procedura di recupero password.</p>
    <br />
    <p>Se hai problemi tecnici o domande in merito al funzionamento del</p>
    <p>portale di monitoraggio, scrivi a <span style="color: #0073e6; line-height: 30.6px;"><a rel="noopener" href="mailto:interop@assistenza.pagopa.it" target="_blank" style="color: #0073e6;">interop@assistenza.pagopa.it</a></span></p>
    <br />
    <p>A presto,</p>
    <p>Il team di PagoPA S.p.A.</p>
      </div>
    
          </td>
        </tr>
      </tbody>
    </table>
    
    <table role="presentation" cellpadding="0" cellspacing="0" width="100%" border="0">
      <tbody>
        <tr>
          <td style="overflow-wrap:break-word;word-break:break-word;padding:10px;" align="left">
            
      <table height="0px" align="left" border="0" cellpadding="0" cellspacing="0" width="542px" style="border-collapse: collapse;table-layout: fixed;border-spacing: 0;mso-table-lspace: 0pt;mso-table-rspace: 0pt;vertical-align: top;border-top: 1px solid #BBBBBB;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%">
        <tbody>
          <tr style="vertical-align: top">
            <td style="word-break: break-word;border-collapse: collapse !important;vertical-align: top;font-size: 0px;line-height: 0px;mso-line-height-rule: exactly;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%">
               <hr style="border: 1px #E3E7EB;">
            </td>
          </tr>
        </tbody>
      </table>
    
          </td>
        </tr>
      </tbody>
    </table>
    
    <table role="presentation" cellpadding="0" cellspacing="0" width="100%" border="0">
      <tbody>
        <tr>
          <td style="overflow-wrap:break-word;word-break:break-word;padding:10px;" align="left">
            
      <div style="font-size: 14px;word-wrap: break-word;">
        <p><span style="color: #ced4d9;"><span style="line-height: 20px;">Ricevi questo messaggio perché hai un’utenza attiva nell’Area Riservata dell’ent</span>e.</span></p>
      </div>
    
          </td>
        </tr>
      </tbody>
    </table>
    
      <!--[if (!mso)&(!IE)]><!--></div><!--<![endif]-->
      </div>
    </div>
    <!--[if (mso)|(IE)]></td><![endif]-->
          <!--[if (mso)|(IE)]></tr></table></td></tr></table><![endif]-->
        </div>
      </div>
    </div>
    
    
        <!--[if (mso)|(IE)]></td></tr></table><![endif]-->
        </td>
      </tr>
      </tbody>
      </table>
      <!--[if mso]></div><![endif]-->
      <!--[if IE]></div><![endif]-->
    </body>
    
    </html>
    `;      
    event.response.emailMessage = message;
    event.response.emailSubject = "Nuova utenza attiva" + envInfo;
  }
  return event;
};  