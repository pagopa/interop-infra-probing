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
               <img class="css-zr5gjd" src="data:image/jpg;base64,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" alt="logo PagoPa"/>
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
               <img class="css-zr5gjd" src="data:image/jpg;base64,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" alt="logo PagoPa"/>
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