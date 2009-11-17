Feature: Language help
  In order to figure out the keywords to use for a language
  I want to be able to get help on the language from the CLI

  Scenario: Get help for Portuguese language
    When I run cucumber -l pt help
    Then it should pass with
      """
      | name                | 'Portuguese'                                |
      | native              | 'português'                                 |
      | encoding            | 'UTF-8'                                     |
      | space_after_keyword | 'true'                                      |
      | feature             | 'Funcionalidade'                            |
      | background          | 'Contexto'                                  |
      | scenario            | 'Cenário' / 'Cenario'                       |
      | scenario_outline    | 'Esquema do Cenário' / 'Esquema do Cenario' |
      | examples            | 'Exemplos'                                  |
      | given               | 'Dado'                                      |
      | when                | 'Quando'                                    |
      | then                | 'Então' / 'Entao'                           |
      | and                 | 'E'                                         |
      | but                 | 'Mas'                                       |

      """
  Scenario: List languages
    When I run cucumber -l help
    Then it should pass with
      """
      | ar      | Arabic                 | العربية              |
      | bg      | Bulgarian              | български            |
      | cat     | Catalan                | català               |
      | cs      | Czech                  | Česky                |
      | cy      | Welsh                  | Cymraeg              |
      | da      | Danish                 | dansk                |
      | de      | German                 | Deutsch              |
      | en      | English                | English              |
      | en-au   | Australian             | Australian           |
      | en-lol  | LOLCAT                 | LOLCAT               |
      | en-tx   | Texan                  | Texan                |
      | es      | Spanish                | español              |
      | et      | Estonian               | eesti keel           |
      | fi      | Finnish                | suomi                |
      | fr      | French                 | français             |
      | he      | Hebrew                 | עברית                |
      | hr      | Croatian               | hrvatski             |
      | hu      | Hungarian              | magyar               |
      | id      | Indonesian             | Bahasa Indonesia     |
      | it      | Italian                | italiano             |
      | ja      | Japanese               | 日本語                  |
      | ko      | Korean                 | 한국어                  |
      | lt      | Lithuanian             | lietuvių kalba       |
      | lv      | Latvian                | latviešu             |
      | nl      | Dutch                  | Nederlands           |
      | no      | Norwegian              | norsk                |
      | pl      | Polish                 | polski               |
      | pt      | Portuguese             | português            |
      | ro      | Romanian               | română               |
      | ro2     | Romanian (diacritical) | română (diacritical) |
      | ru      | Russian                | русский              |
      | se      | Swedish                | Svenska              |
      | sk      | Slovak                 | Slovensky            |
      | sr      | Serbian                | Српски               |
      | sr-Latn | Serbian_latin          | Srpski_latinica      |
      | tr      | Turkish                | Türkçe               |
      | uz      | Uzbek                  | Узбекча              |
      | vi      | Vietnamese             | Tiếng Việt           |
      | zh-CN   | Chinese simplified     | 简体中文                 |
      | zh-TW   | Chinese traditional    | 繁體中文                 |

      """
