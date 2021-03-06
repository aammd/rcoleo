#' Publication des observations d'une campagne sur la base de données de Coléo
#'
#' Cette fonction applique la méthode POST sur le point d'entrées `observations` de l'API de Coleo
#'
#' @inheritParams post_cells
#' @export

post_obs <- function(data, ...) {

  # Preparation de l'objet de sortie
  responses <- list()
  class(responses) <- "coleoPostResp"
  
  endpoint <- endpoints()$observations

  for (i in 1:length(data)) {
    responses[[i]] <- post_gen(endpoint, data[[i]], ...)
  }

  return(responses)
}
