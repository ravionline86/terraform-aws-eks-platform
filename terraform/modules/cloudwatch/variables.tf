variable "cluster_name"       { type = string }
variable "log_retention_days" { type = number; default = 14 }
variable "alert_email"        { type = string; default = "" }
variable "tags"               { type = map(string); default = {} }
