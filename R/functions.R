sCline <- function(a,b) {
  ## link
  linkfun <- function(y) log((a-y)/(y-b))
  ## inverse link
  linkinv <- function(eta)  (exp(eta)*b + a)/(exp(eta)+1)
  ## derivative of invlink wrt eta
  mu.eta <- function(eta) { exp(eta)*(b-a)/(exp(eta)+1)^2 }
  valideta <- function(eta) TRUE
  link <- "log((a-y)/(y-b))"
  structure(list(linkfun = linkfun, linkinv = linkinv,
                 mu.eta = mu.eta, valideta = valideta, 
                 name = link),
            class = "link-glm")
}

# plot label modifiers
sign_labeller <- function(variable, value) {
  sign_names[value]
}
tissue_labeller <- function(variable,value) {
  tissue_names[value]
}
