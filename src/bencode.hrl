-record(torrentfile, {announce :: string() | []
                    ,comment :: string()
                    ,created_by :: number()
                    ,creation_date :: string()
                    ,encoding :: string()
                    ,length :: number() | []
                    ,name :: string()
                    ,piece_len :: integer()
                    ,pieces :: string()
                    ,private :: boolean()
                    }).
