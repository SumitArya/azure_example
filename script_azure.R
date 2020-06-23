library(AzureAuth)
library(shiny)

#AzureR_dir()

resource <- "https://graph.microsoft.com/"
tenant <- "0cbaf9a3-edc1-411b-a71c-0ad85950637b"
app <- "4e908bde-ee24-4116-8f50-e1cf251716dc"
scope <- "api://265f06c2-cc01-442a-a6ca-f763a48adabc"

# set this to the site URL of your app once it is deployed
# this must also be the redirect for your registered app in Azure Active Directory
redirect <- "http://localhost:8100"

options(shiny.port=as.numeric(httr::parse_url(redirect)$port))

# replace this with your app's regular UI
ui <- fluidPage(
  verbatimTextOutput("token")
)

ui_func <- function(req){
  opts <- parseQueryString(req$QUERY_STRING)
  if(is.null(opts$code))
  {
    auth_uri <- build_authorization_uri(resource, tenant, app, redirect_uri=redirect)
    redir_js <- sprintf("location.replace(\"%s\");", auth_uri)
    tags$script(HTML(redir_js))
  }
  else ui
}

server <- function(input, output, session)
{
  opts <- parseQueryString(isolate(session$clientData$url_search))
  if(is.null(opts$code))
    return()
  
  # this assumes your app has a 'public client/native' redirect:
  # if it is a 'web' redirect, include the client secret as the password argument
  token <- get_azure_token(resource, tenant, app,
                           authorize_args=list(redirect_uri=redirect),
                           use_cache=FALSE, auth_code=opts$code)
  
  output$token <- renderPrint("I am running")
}

shinyApp(ui_func, server)