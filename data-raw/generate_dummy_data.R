

xlsform_fill_loop <- function (tool.path = "",language = "English", n = 100) {

  ## Start a data list
  data.list <- list()

  if(tool.path == "") {
    stop("Please provide a path to the XLS form tool")
  }


  survey <- readxl::read_xlsx(tool.path, sheet = "survey", col_types = "text")

  ## catch the label_colname
  tool_colnames <- survey %>% names
  label_colname <- tool_colnames[agrep(paste0("label::",language), tool_colnames)]

  if(is_empty(label_colname)) {
    stop("Please provide the correct language used in the tool (e.g.language = 'English' if label::English)")
  }

  ## create tool.survey
  tool.survey <- survey %>%
    filter(!is.na(type)) %>%
    mutate(q.type=as.character(lapply(type, function(x) str_split(x, " ")[[1]][1])),
           list_name=as.character(lapply(type, function(x) str_split(x, " ")[[1]][2])),
           list_name=ifelse(str_starts(type, "select_"), list_name, NA))

  # Find which data sheet question belongs to:
  tool.survey <- tool.survey %>% mutate(datasheet = NA)
  sheet_name <- "main"
  for(i in 1:nrow(tool.survey)){
    toolrow <- tool.survey %>% slice(i)
    if(str_detect(toolrow$type, "begin[ _]repeat")) sheet_name <- toolrow$name
    else if(str_detect(toolrow$type, "end[ _]repeat")) sheet_name <- "main"   # watch out for nested repeats (Why would you even want to do that?)
    else if(str_detect(toolrow$type, "((end)|(begin))[ _]group", T)) tool.survey[i, "datasheet"] <- sheet_name
  }

  ## create tool.choices

  tool.survey <- tool.survey %>% mutate(count_repeat = NA)
  repeat_c <- NA
  for(i in 1:nrow(tool.survey)){
    toolrow <- tool.survey %>% slice(i)
    if(str_detect(toolrow$type, "begin[ _]repeat")) repeat_c <- toolrow$repeat_count
    else if(str_detect(toolrow$type, "end[ _]repeat")) repeat_c <- NA   # watch out for nested repeats (Why would you even want to do that?)
    else if(str_detect(toolrow$type, "((end)|(begin))[ _]group", T)) tool.survey[i, "count_repeat"] <- repeat_c
  }

  choices <- read_xlsx(tool.path, sheet = "choices", col_types = "text") %>%
    filter(!is.na(list_name)) %>%
    select(all_of(c("list_name", "name")), !!sym(label_colname)) %>% distinct()

  ## Start of the tool
  sheets <- unique(tool.survey$datasheet)
  sheets <- sheets[!is.na(sheets)&sheets!="main"]
  questions <- tool.survey[tool.survey$datasheet == "main", ]
  questions <- questions[!is.na(questions$name), ]
  questions$name <- as.character(questions$name)
  questions$relevant <- as.character(questions$relevant)
  q <- get_questionnaire_functions(questions, choices)
  get_choices <- choices_of_question_funfact(questions, choices)
  repeat_count <- gsub("[$|{|}]","",unique(tool.survey$count_repeat))
  repeat_count <- repeat_count[!is.na(repeat_count)]
  get_raw_type <- function(varname) {
    raw_type <- questions$type[match(varname, questions$name)][1]
    if (grepl("select_one", raw_type)) {
      return("select_one")
    }
    if (grepl("select_multiple", raw_type)) {
      return("select_multiple")
    }
    if (grepl("select_multiple", raw_type)) {
      return("select_multiple")
    }
    return(raw_type)
  }

  filled <- tibble::tibble(1:n)[, 0]
  for(i in 1:length(questions$name)){
    varname <- questions$name[i]
    constraint <- questions$constraint[i]
    if(!is.na(constraint)){
      constraint1 = gsub("\\$\\{|\\}", "", constraint)
      constraint2 = gsub("not\\s*\\(", "!(", constraint1)
      constraint3 = gsub("\\bor\\b", "|", constraint2, ignore.case = TRUE)
      constraint4 = gsub("\\band\\b", "&", constraint3, ignore.case = TRUE)
      constraint5 = gsub("(?<!\\!|>|<)=(?![>=<])", "==", constraint4, perl = TRUE)
    }

    filling <- tibble::tibble(1:n)[, 0]
    if (get_raw_type(varname) == "start") {
      filling <- fill_datetime(varname, n)
    }
    if (get_raw_type(varname) == "end") {
      filling <- fill_datetime(varname, n)
    }
    if (get_raw_type(varname) == "deviceid") {
      filling <- fill_deviceid(varname, n)
    }
    if (get_raw_type(varname) == "date") {
      filling <- fill_datetime(varname, n)
    }
    if (get_raw_type(varname) == "time") {
      filling <- fill_datetime(varname, n)
    }
    if (tolower(get_raw_type(varname)) == "datetime") {
      filling <- fill_datetime(varname, n)
    }
    if (get_raw_type(varname) == "text") {
      filling <- fill_text(varname, n)
    }
    if (get_raw_type(varname) == "decimal") {
      if(!is.na(constraint)){
        filling <- fill_decimal_constraint(varname, n, constraint5)
      } else{
        if(varname %in% repeat_count){
          filling <- fill_decimal(varname, n,div = 5)
        }else{
          filling <- fill_decimal(varname, n)
        }
      }
    }
    if (get_raw_type(varname) == "integer") {
      if(!is.na(constraint) & varname %in% repeat_count){
        bounds <- extract_constraints(constraint5)
        if(bounds$upper_bound == 100){
          filling <- fill_integer(varname, n,div = 5)
        } else {
          filling <- fill_integer_constraint(varname, n, constraint5)
        }
      } else if(!is.na(constraint) & !varname %in% repeat_count){
        filling <- fill_integer_constraint(varname, n, constraint5)
      } else{
        if(varname %in% repeat_count){
          filling <- fill_integer(varname, n,div = 5)
        }else{
          filling <- fill_integer(varname, n)
        }
      }
    }
    if (get_raw_type(varname) == "calculate") {
      filling <- fill_calculate_placeholder(varname, n)
    }
    if (q$question_is_select_one(varname)) {
      filling <- fill_select_one(varname, n, get_choices(varname))
    }
    if (q$question_is_select_multiple(varname)) {
      filling <- fill_select_multiple(varname, n, get_choices(varname))
    }
    filled <- cbind(filled,filling)
  }
  filled[["uuid"]] <- fill_uuid("uuid", n)[["uuid"]]
  # filled[["person_id"]] <- fill_person_id("person_id", n)[["person_id"]]
  filled[["index"]] <- fill_index("index", n)[["index"]]
  original_colnames <- colnames(filled)
  simplified_colnames <- to_alphanumeric_lowercase(colnames(filled))
  colnames(filled) <- simplified_colnames
  filled <- add_form_calculations(filled, questions)
  filled <- remove_skipped_values(filled, q)
  colnames(filled) <- original_colnames
  filled_skipped <- skip_data(tool.survey,filled)
  data.list[["main"]] <- filled_skipped
  for(sheet in sheets){
    questions <- tool.survey[tool.survey$datasheet == sheet, ]
    questions <- questions[!is.na(questions$name), ]
    questions$name <- as.character(questions$name)
    questions$relevant <- as.character(questions$relevant)
    q <- get_questionnaire_functions(questions, choices)
    get_choices <- choices_of_question_funfact(questions, choices)
    get_raw_type <- function(varname) {
      raw_type <- questions$type[match(varname, questions$name)][1]
      if (grepl("select_one", raw_type)) {
        return("select_one")
      }
      if (grepl("select_multiple", raw_type)) {
        return("select_multiple")
      }
      if (grepl("select_multiple", raw_type)) {
        return("select_multiple")
      }
      return(raw_type)
    }
    count <- as.numeric(data.list$main[,gsub("[${]|[}]","",unique(questions$count_repeat))])
    count[which(is.na(count))] <- 0
    filled_skipped_binded <- data.frame()
    pb <- txtProgressBar(min = 0, max = length(count), style = 3)
    if(length(count)>0){
      for(i in 1:length(count)){
        setTxtProgressBar(pb, i)
        n_loop <- count[i]
        if(n_loop!=0){

          filled <- lapply(questions$name, function(varname) {
            constraint <- questions[which(questions$name == varname),"constraint"] %>% pull
            if(!is.na(constraint)){
              constraint1 = gsub("\\$\\{|\\}", "", constraint)
              constraint2 = gsub("not\\s*\\(", "!(", constraint1)
              constraint3 = gsub("\\bor\\b", "|", constraint2, ignore.case = TRUE)
              constraint4 = gsub("\\band\\b", "&", constraint3, ignore.case = TRUE)
              constraint5 = gsub("(?<!\\!|>|<)=(?![>=<])", "==", constraint4, perl = TRUE)
            }

            filling <- tibble::tibble(1:n_loop)[, 0]
            if (get_raw_type(varname) == "start") {
              filling <- fill_datetime(varname, n_loop)
            }
            if (get_raw_type(varname) == "end") {
              filling <- fill_datetime(varname, n_loop)
            }
            if (get_raw_type(varname) == "deviceid") {
              filling <- fill_deviceid(varname, n_loop)
            }
            if (get_raw_type(varname) == "date") {
              filling <- fill_datetime(varname, n_loop)
            }
            if (get_raw_type(varname) == "time") {
              filling <- fill_datetime(varname, n_loop)
            }
            if (tolower(get_raw_type(varname)) == "datetime") {
              filling <- fill_datetime(varname, n_loop)
            }
            if (get_raw_type(varname) == "text") {
              filling <- fill_text(varname, n_loop)
            }
            if (get_raw_type(varname) == "decimal") {
              if(!is.na(constraint)){
                filling <- fill_decimal_constraint(varname, n_loop, constraint5)
              } else{
                if(varname %in% repeat_count){
                  filling <- fill_decimal(varname, n_loop, div = 5)
                }else{
                  filling <- fill_decimal(varname, n_loop)
                }
              }
            }
            if (get_raw_type(varname) == "integer") {
              if(!is.na(constraint) & varname %in% repeat_count){
                bounds <- extract_constraints(constraint5)
                if(bounds$upper_bound == 100){
                  filling <- fill_integer(varname, n_loop, div = 5)
                } else {
                  filling <- fill_integer_constraint(varname, n_loop, constraint5)
                }
              } else if(!is.na(constraint) & !varname %in% repeat_count){
                filling <- fill_integer_constraint(varname, n_loop, constraint5)
              } else{
                if(varname %in% repeat_count){
                  filling <- fill_integer(varname, n_loop, div = 5)
                }else{
                  filling <- fill_integer(varname, n_loop)
                }
              }
            }
            if (get_raw_type(varname) == "calculate") {
              filling <- fill_calculate_placeholder(varname, n_loop)
            }
            if (q$question_is_select_one(varname)) {
              filling <- fill_select_one(varname, n_loop, get_choices(varname))
            }
            if (q$question_is_select_multiple(varname)) {
              filling <- fill_select_multiple(varname, n_loop, get_choices(varname))
            }
            filling
          }) %>% do.call(cbind, .)
          filled[["uuid"]] <- filled_skipped$uuid[i]
          # filled[["person_id"]] <- fill_person_id("person_id", n_loop)[["person_id"]]
          filled[["_parent_index"]] <- filled_skipped$index[i]
          original_colnames <- colnames(filled)
          simplified_colnames <- to_alphanumeric_lowercase(colnames(filled))
          colnames(filled) <- simplified_colnames
          filled <- add_form_calculations(filled, questions)
          filled <- remove_skipped_values(filled, q)
          colnames(filled) <- original_colnames
          filled <-  skip_data(questions,filled)
          filled_skipped_binded <- rbind(filled_skipped_binded,filled)
        }
      }
      close(pb)
      data.list[[sheet]] <- filled_skipped_binded %>%
        mutate(`_index` = 1:nrow(filled_skipped_binded))
    }
  }
  return(data.list)
}

skipped_values<-function(data,questionnaire){

  lapply(names(data),function(x){

    tryCatch({questionnaire$question_is_skipped(data,x)},error=function(e){
      warning(paste0("failed applying skiplogic for '",x,"' with error: ",e$message))
      rep(FALSE,nrow(data))})
  }) %>% as.data.frame(stringsAsFactors=F)
}



remove_skipped_values<-function(data,questionnaire){
  skipped<-skipped_values(data,questionnaire)

  for(i in ncol(data)){
    data[which(skipped[,i]),i]<-NA

  }
  data
}
add_form_calculations<-function(data,questions){
  get_raw_type<-function(varname){questions$type[match(varname,questions$name)][1]}
  calculate_varnames<-questions$name[which(sapply(questions$name,get_raw_type)=="calculate")]
  get_calculation<-function(varname){questions$calculation[match(varname,questions$name)][1]}

  for(varname in calculate_varnames){
    data[[varname]]<-fill_calculate(varname,
                                    kobo_calculation = get_calculation(varname),
                                    other_data = data)[[varname]]

  }
  data
}




get_questionnaire_functions<-function(questions,choices){
  empty_data<-as.data.frame(lapply(questions$name,function(x){NA}))
  names(empty_data)<-questions$name
  empty_data<-empty_data[,!is.na(names(empty_data))]
  q <- koboquest::load_questionnaire(empty_data,questions,choices)
  q
}





choices_of_question_funfact<-function (questions, choices){


  names(questions) <- to_alphanumeric_lowercase(names(questions))
  names(choices) <- to_alphanumeric_lowercase(names(choices))

  data_colnames <- to_alphanumeric_lowercase(questions$name)

  # questions <- questions[match(data_colnames, questions$name),
  #                        ]
  # if (length(grep("^list[\\._]name$", "list_name", value = T)) <
  #     1) {
  #   stop("kobo 'choices' sheet must have a column named 'list.name' or 'list_name'")
  # }
  choices_per_data_column <- questions$type %>% as.character %>%
    strsplit(" ") %>% lapply(unlist) %>% lapply(function(x) {
      x %>% lapply(function(y) {
        grep(paste0(" ", y, " "), paste0(" ", choices[[grep("^list[\\._]name$",
                                                            names(choices), value = T)[1]]], " "), value = F,
             fixed = T)
      }) %>% unlist
    }) %>% lapply(hasdata) %>% lapply(function(x) {
      choices[x, ]
    })


  names(choices_per_data_column) <- data_colnames

  get_choices<-function(varname){
    varname<-to_alphanumeric_lowercase(varname)
    choices_per_data_column[[varname]]$name

  }
  return(get_choices)

}

hasdata<-function (x, return.index = F) {
  index <- which(!is.null(x) & !is.na(x) & x != "" & !is.infinite(x))
  value <- x[which(!is.null(x) & !is.na(x) & x != "" & !is.infinite(x))]
  if (return.index) {
    return(index)
  }
  return(value)
}


to_alphanumeric_lowercase <- function(x){tolower(gsub("[^a-zA-Z0-9_]", "\\.", x))}
to_alphanumeric_lowercase_colnames_df <- function(df){
  names(df) <- to_alphanumeric_lowercase(names(df))
  return(df)
}


generate_uuid <- function(...) {
  uppercase<-FALSE
  hex_digits <- c(as.character(0:9), letters[1:6])
  hex_digits <- if (uppercase) toupper(hex_digits) else hex_digits

  y_digits <- hex_digits[9:12]

  paste(
    paste0(sample(hex_digits, 8), collapse=''),
    paste0(sample(hex_digits, 4), collapse=''),
    paste0('4', sample(hex_digits, 3), collapse=''),
    paste0(sample(y_digits,1),
           sample(hex_digits, 3),
           collapse=''),
    paste0(sample(hex_digits, 12), collapse=''),
    sep='-')
}


fill_decimal<-function(varname,n,div=1){

  filling<- tibble::tibble(abs((rnorm(n)*2)+20)/5)
  colnames(filling)<-varname
  filling
}
fill_decimal_constraint<-function(varname,n, constraint_message){

  filling<- tibble::tibble(generate_random_numbers(n,constraint_message, round = F))
  colnames(filling)<-varname
  filling
}
fill_integer<-function(varname,n,div = 1){
  filling<- tibble::tibble(round(abs((rnorm(n)*2)+20)/div))
  colnames(filling)<-varname
  filling
}
fill_integer_constraint<-function(varname,n,constraint_message){
  filling<- tibble::tibble(generate_random_numbers(n,constraint_message, round = T))
  colnames(filling)<-varname
  filling
}
fill_text<-function(varname,n){
  filling<- tibble::tibble(stringi::stri_rand_strings(n,length = round(runif(n,max=100)),pattern = "[A-Za-z\\ ]"))
  colnames(filling)<-varname
  filling
}


fill_deviceid<-function(varname,n){
  n_devices<-round(n/50)
  if(n_devices<10){n_devices<-10}
  deviceids<-sprintf("deviceID%08d", 0:n_devices)
  filling<- tibble::tibble(sample(deviceids,n,T))
  colnames(filling)<-varname
  filling
}



fill_select_one<-function(varname,n,options){
  if(length(options)==0){
    options<-NA
    warning(paste0("no choices found for variable: '",varname,"' - filling this select_one with NA"))
    filling<- tibble::tibble(rep(NA,n))
    colnames(filling)<-varname
    return(filling)
  }
  options<-as.character(options)
  options<-unique(options)
  options<-factor(options,levels = options)


  filling<- tibble::tibble(sample(options,n,T))
  colnames(filling)<-varname
  filling
}


fill_select_multiple<-function(varname,n,options){
  if(length(options)==0){
    warning(paste0("no choices found for variable: '",varname,"' - ignoring this select_multiple"))
    return(tibble::tibble(1:n)[,0])
  }
  options<-as.character(options)
  options<-unique(options)
  filling_logical<-matrix(sample(c(1,0),n*length(options),T, prob = c(0.3,0.7)),nrow = n)
  colnames(filling_logical)<-paste0(varname,"/",options)

  filling_concatenated_choices<- tibble::tibble(apply(filling_logical,1,function(x){paste0(options[which(x == 1)],collapse=" ")}))
  colnames(filling_concatenated_choices)<-varname

  tibble::as_tibble(cbind(filling_concatenated_choices,filling_logical,stringsAsFactors=F))

}

fill_datetime<-function(varname,n){
  date_0<-Sys.time()
  filling<- tibble::tibble(date_0 - runif(n,min=0,max=10000))
  filling[,1]<-format.Date(as.data.frame(filling)[,1],"%Y-%m-%dT%H:%M:%S%z") %>% as.character
  colnames(filling)<-varname
  filling
}




fill_uuid<-function(varname,n){
  filling<- tibble::tibble(sapply(1:n,generate_uuid))
  colnames(filling)<-varname
  filling
}

fill_person_id<-function(varname,n){
  filling<- tibble::tibble(sapply(1:n,generate_uuid))
  colnames(filling)<-varname
  filling
}



fill_index<-function(varname,n){
  filling<- tibble::tibble(1:n)
  colnames(filling)<-varname
  filling
}


fill_calculate_placeholder<-function(varname,n){
  filling<- tibble::tibble(rep(NA,n))
  colnames(filling)<-varname
  filling
}



fill_calculate<-function(varname,kobo_calculation,other_data){

  calculation_as_rcode<-koboquest:::rify_condition(kobo_calculation)

  names(other_data)<-to_alphanumeric_lowercase(names(other_data))

  coalesce<-function(x,y){
    if(is.na(x) | x==""){
      return(y)
    }
    return(x)
  }
  not<-function(x){!x}

  today<-Sys.Date

  if(calculation_as_rcode==""){calculation_as_rcode<-"rep(NA,nrow(other_data))"}
  calc_result<-tryCatch({purrr::pmap(.l = other_data
                                     ,.f = function(...){
                                       dots<-list(...);
                                       with(dots,{

                                         calc_result<-eval(parse(text=calculation_as_rcode))
                                         if(length(calc_result)!=1){
                                           stop(paste0("filling '",varname,"' with NA. Calculation did not produce one value per data row."))
                                         }
                                         calc_result
                                       })
                                     })},
                        error=function(e){
                          warning(paste0("\nfilling '",varname,"' with NA. Calculation failed with error: \n",e$message))
                          rep(NA,nrow(other_data))
                        })

  calc_result<-unlist(calc_result)
  filling<- tibble::tibble(calc_result)
  colnames(filling)<-varname
  return(filling)
}


## FUNCTION FOR HANDLING SKIP LOGIC
skip_data <- function(tool, df){
  group_stack <- character(0)

  # Initialize a list to store question-group mappings
  question_group_mapping <- list()

  # The following loop will populate question_group_mapping, for each question, it will add the list of groups (one or more nested groups) that the question belongs to
  for (i in 1:nrow(tool)) {

    question_type <- tool$type[i]
    question_name <- tool$name[i]


    if (question_type == "begin_group") {
      group_name <- tool$name[i]
      group_stack <- c(group_stack, group_name)
    } else if (question_type == "end_group") {
      group_stack <- group_stack[-length(group_stack)]
    }

    else {
      question_group_mapping[[question_name]] <- group_stack
      # print(sprintf("i: %s - %s, list: %s",i,question_name,group_stack |> paste(collapse = '/')))

    }}


  # Transforming the relevancy constraints in kobo into an R code that can be executed inside a mutate verb

  tool <- tool |> mutate(
    transformation1 = gsub("\\$\\{|\\}", "", relevant),
    transformation2 = gsub("not\\s*\\(", "!(", transformation1),
    transformation3 = gsub("\\bor\\b", "|", transformation2, ignore.case = TRUE),
    transformation4 = gsub("\\band\\b", "&", transformation3, ignore.case = TRUE),
    transformation5 = gsub("(?<!\\!|>|<)=(?![>=<])", "==", transformation4, perl = TRUE)

  )

  # defining the select function that will simply call sm_selected from composr
  selected <- function(question,choice) {
    composr::sm_selected(x = question, any = choice)
  }


  get_relevancy <- function(name) {
    if (!is.na(tool[min(which(tool$name == name)),"relevant"])) {
      return(sprintf("(%s)",as.character(tool[min(which(tool$name == name)),"transformation5"])))
    }
    return("")
  }


  df_out <- df |> select(uuid)

  for (i in 1:nrow(tool)) {
    name <- tool$name[i]
    if (!name %in% names(df)) next

    expression <- tool$transformation5[i]


    if(length(question_group_mapping[[name]])>0) {

      h <- map_chr(question_group_mapping[[name]],get_relevancy)
      h <- h[h!=""]
      h <- paste(h,collapse = " & ")
      if (h!="") {
        if (!is.na(expression)) {
          expression = sprintf("(%s) & (%s)",expression,h)
        } else {
          expression = h
        }
      }
    }

    if(is.na(expression)) {
      expression = "TRUE"
    }
    #
    # print(expression)

    result <- df %>%
      transmute(!!paste(name, sep = "") := eval(parse(text = expression)))

    df_out <- cbind(df_out, result)
  }

  df_result <- df

  for (col_ind in 2:ncol(df_out) ) {
    ## implemented the skip logic to the boolean values
    sm_col_ind <- paste0(names(df_out[col_ind]),"/")
    df_result[which(df_out[[col_ind]]==FALSE),which(names(df_result) == names(df_out)[col_ind])] = NA
    df_result[which(df_out[[col_ind]]==FALSE),which(grepl(sm_col_ind,names(df_result)))] = NA
  }
  return(df_result)
}


### FUNCTIONS FOR CONSTRAINT IN INTEGER AND DECIMAL
extract_constraints <- function(constraint_message, lower_cutoff = 0, upper_cutoff = 100) {
  # Split the constraint message by '&' if it exists to handle both bounds
  constraints_parts <- unlist(strsplit(constraint_message, "&"))

  # Initialize boundaries with NULL to indicate they might not be specified
  lower_bound <- NULL
  upper_bound <- NULL

  # Function to adjust bounds based on the type of constraint
  adjust_bound <- function(constraint) {
    if (grepl("\\.>=", constraint)) {
      return(as.numeric(gsub(".*\\.>=(\\d+).*", "\\1", constraint)))
    } else if (grepl("\\.>", constraint)) {
      return(as.numeric(gsub(".*\\.>(\\d+).*", "\\1", constraint)) + .Machine$double.eps)
    } else if (grepl("\\.<=", constraint)) {
      return(as.numeric(gsub(".*\\.<=(\\d+).*", "\\1", constraint)))
    } else if (grepl("\\.<", constraint)) {
      return(as.numeric(gsub(".*\\.<(\\d+).*", "\\1", constraint)) - .Machine$double.eps)
    }
    return(NULL)
  }

  # Iterate through each part to determine the bounds
  for (constraint in constraints_parts) {
    if (grepl("\\.>=", constraint) | grepl("\\.>", constraint)) {
      lower_bound <- adjust_bound(constraint)
    } else if (grepl("\\.<=", constraint) | grepl("\\.<", constraint)) {
      upper_bound <- adjust_bound(constraint)
    }
  }
  # Adjust default values based on extracted constraints
  if(is.null(lower_bound)) {
    # Set a reasonable default lower bound if not specified
    lower_bound <- lower_cutoff
  } else {
    lower_bound <- lower_bound
  }

  if(is.null(upper_bound)) {
    # Set a reasonable default upper bound if not specified
    upper_bound <- upper_cutoff
  } else {
    upper_bound <- upper_bound
  }
  # Return a list containing the lower and upper bounds
  return(list(lower_bound = lower_bound, upper_bound = upper_bound))
}

generate_random_numbers <- function(n, constraint_message, round = T) {
  # Extract min and max values from the constraint message
  constraint_message
  constraint_message <- gsub(" ","",constraint_message)
  # Extract constraints
  constraints <- extract_constraints(constraint_message)


  if(round){
    # Generate n random numbers within the specified range
    random_numbers <- round(runif(n, min = constraints$lower_bound, max = constraints$upper_bound),0)
  } else{
    # Generate n random numbers within the specified range
    random_numbers <- round(runif(n, min = constraints$lower_bound, max = constraints$upper_bound),2)
  }
  return(random_numbers)
}


# rm(list = ls())
# loading all packages, functions and the Kobo tool
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, readxl, writexl, openxlsx, randomcoloR, sf, anytime, DT,
               cluster, survey, srvyr, knitr, webshot, docstring, tcltk, scales,svDialogs)
# source("src/functions_create_dummy.R")
num <- as.numeric(svDialogs::dlg_input(message = "Please enter the number of submission to create the dummy data (only real number)")$res)
# tool_path <- choose.files("data-raw/REACH_2024_MSNA-kobo-tool_draft_v8.xlsx", caption ="Please select the tool to create the dummy data.", multi = F)
data <- xlsform_fill_loop("data-raw/REACH_2024_MSNA-kobo-tool_draft_v10.xlsx", n = num)

# Sensitive data removed write excel
sheetsbinded <- list("main" = data$main,
                     "roster" = data$roster,
                     "edu_ind" = data$edu_ind,
                     "health_ind" = data$health_ind,
                     "nut_ind" = data$nut_ind)
sheetsbinded <- lapply(sheetsbinded, function(x) x |> dplyr::as_tibble())
sheetsbinded <- lapply(sheetsbinded, function(x) x |>
                        rownames_to_column("row_id") |>
                        mutate(person_id = paste0(uuid, "-", row_id)))
sheetsbinded <- lapply(sheetsbinded, function(x) x |> mutate(across(where(~ is.factor(.x)), \(t) as.character(t))))
sheetsbinded$edu_ind$edu_person_id <- sheetsbinded$edu_ind$person_id
sheetsbinded$health_ind$health_person_id <- sheetsbinded$health_ind$person_id
sheetsbinded$nut_ind$nut_person_id <- sheetsbinded$nut_ind$person_id
write.xlsx(sheetsbinded, paste0("data-raw/dummy_raw_data.xlsx"), overwrite = T)
dummy_raw_data <- sheetsbinded
# library(impactR.utils)
# dummy_raw_data <- impactR.utils::import_full_xlsx("data-raw/dummy_raw_data.xlsx", clean_names = F)
usethis::use_data(dummy_raw_data, overwrite = TRUE)

