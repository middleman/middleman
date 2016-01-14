class Middleman::Extensions::Lorem < ::Middleman::Extension
  helpers do
    # Access to the Lorem object
    # @return [Middleman::Extensions::Lorem::LoremObject]
    def lorem
      LoremObject
    end

    # Return a placeholder image using placekitten.com
    #
    # @param [String] size
    # @param [Hash] options
    # @return [String]
    def placekitten(size, options={})
      options[:domain] = 'http://placekitten.com'
      lorem.image(size, options)
    end
  end

  # Adapted from Frank:
  # https://github.com/blahed/frank/
  # Copyright (c) 2010 Travis Dunn
  #
  #   Permission is hereby granted, free of charge, to any person
  #   obtaining a copy of this software and associated documentation
  #   files (the "Software"), to deal in the Software without
  #   restriction, including without limitation the rights to use,
  #   copy, modify, merge, publish, distribute, sublicense, and/or sell
  #   copies of the Software, and to permit persons to whom the
  #   Software is furnished to do so, subject to the following
  #   conditions:
  #
  #   The above copyright notice and this permission notice shall be
  #   included in all copies or substantial portions of the Software.
  #
  #   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  #   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
  #   OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  #   NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
  #   HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
  #   WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  #   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
  #   OTHER DEALINGS IN THE SOFTWARE.
  module LoremObject
    class << self
      # Words for use in lorem text
      WORDS = %w(alias consequatur aut perferendis sit voluptatem accusantium doloremque aperiam eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo aspernatur aut odit aut fugit sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt neque dolorem ipsum quia dolor sit amet consectetur adipisci velit sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem ut enim ad minima veniam quis nostrum exercitationem ullam corporis nemo enim ipsam voluptatem quia voluptas sit suscipit laboriosam nisi ut aliquid ex ea commodi consequatur quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae et iusto odio dignissimos ducimus qui blanditiis praesentium laudantium totam rem voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident sed ut perspiciatis unde omnis iste natus error similique sunt in culpa qui officia deserunt mollitia animi id est laborum et dolorum fuga et harum quidem rerum facilis est et expedita distinctio nam libero tempore cum soluta nobis est eligendi optio cumque nihil impedit quo porro quisquam est qui minus id quod maxime placeat facere possimus omnis voluptas assumenda est omnis dolor repellendus temporibus autem quibusdam et aut consequatur vel illum qui dolorem eum fugiat quo voluptas nulla pariatur at vero eos et accusamus officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae itaque earum rerum hic tenetur a sapiente delectus ut aut reiciendis voluptatibus maiores doloribus asperiores repellat).freeze

      # Get one placeholder word
      # @return [String]
      def word
        words(1)
      end

      # Get some number of placeholder words
      # @param [Fixnum] total
      # @return [String]
      def words(total)
        (1..total).map do
          randm(WORDS)
        end.join(' ')
      end

      # Get one placeholder sentence
      # @return [String]
      def sentence
        sentences(1)
      end

      # Get some number of placeholder sentences
      # @param [Fixnum] total
      # @return [String]
      def sentences(total)
        (1..total).map do
          words(randm(4..15)).capitalize
        end.join('. ')
      end

      # Get one placeholder paragraph
      # @return [String]
      def paragraph
        paragraphs(1)
      end

      # Get some number of placeholder paragraphs
      # @param [Fixnum] total
      # @return [String]
      def paragraphs(total)
        (1..total).map do
          sentences(randm(3..7)).capitalize
        end.join("\n\n")
      end

      # Get a placeholder date
      # @param [String] fmt
      # @return [String]
      def date(fmt='%a %b %d, %Y')
        y = rand(20) + 1990
        m = rand(12) + 1
        d = rand(31) + 1
        Time.local(y, m, d).strftime(fmt)
      end

      # Get a placeholder name
      # @return [String]
      def name
        "#{first_name} #{last_name}"
      end

      # Get a placeholder first name
      # @return [String]
      def first_name
        names = 'Judith Angelo Margarita Kerry Elaine Lorenzo Justice Doris Raul Liliana Kerry Elise Ciaran Johnny Moses Davion Penny Mohammed Harvey Sheryl Hudson Brendan Brooklynn Denis Sadie Trisha Jacquelyn Virgil Cindy Alexa Marianne Giselle Casey Alondra Angela Katherine Skyler Kyleigh Carly Abel Adrianna Luis Dominick Eoin Noel Ciara Roberto Skylar Brock Earl Dwayne Jackie Hamish Sienna Nolan Daren Jean Shirley Connor Geraldine Niall Kristi Monty Yvonne Tammie Zachariah Fatima Ruby Nadia Anahi Calum Peggy Alfredo Marybeth Bonnie Gordon Cara John Staci Samuel Carmen Rylee Yehudi Colm Beth Dulce Darius inley Javon Jason Perla Wayne Laila Kaleigh Maggie Don Quinn Collin Aniya Zoe Isabel Clint Leland Esmeralda Emma Madeline Byron Courtney Vanessa Terry Antoinette George Constance Preston Rolando Caleb Kenneth Lynette Carley Francesca Johnnie Jordyn Arturo Camila Skye Guy Ana Kaylin Nia Colton Bart Brendon Alvin Daryl Dirk Mya Pete Joann Uriel Alonzo Agnes Chris Alyson Paola Dora Elias Allen Jackie Eric Bonita Kelvin Emiliano Ashton Kyra Kailey Sonja Alberto Ty Summer Brayden Lori Kelly Tomas Joey Billie Katie Stephanie Danielle Alexis Jamal Kieran Lucinda Eliza Allyson Melinda Alma Piper Deana Harriet Bryce Eli Jadyn Rogelio Orlaith Janet Randal Toby Carla Lorie Caitlyn Annika Isabelle inn Ewan Maisie Michelle Grady Ida Reid Emely Tricia Beau Reese Vance Dalton Lexi Rafael Makenzie Mitzi Clinton Xena Angelina Kendrick Leslie Teddy Jerald Noelle Neil Marsha Gayle Omar Abigail Alexandra Phil Andre Billy Brenden Bianca Jared Gretchen Patrick Antonio Josephine Kyla Manuel Freya Kellie Tonia Jamie Sydney Andres Ruben Harrison Hector Clyde Wendell Kaden Ian Tracy Cathleen Shawn'.split(' ')
        names[rand(names.size)]
      end

      # Get a placeholder last name
      # @return [String]
      def last_name
        names = "Chung Chen Melton Hill Puckett Song Hamilton Bender Wagner McLaughlin McNamara Raynor Moon Woodard Desai Wallace Lawrence Griffin Dougherty Powers May Steele Teague Vick Gallagher Solomon Walsh Monroe Connolly Hawkins Middleton Goldstein Watts Johnston Weeks Wilkerson Barton Walton Hall Ross Chung Bender Woods Mangum Joseph Rosenthal Bowden Barton Underwood Jones Baker Merritt Cross Cooper Holmes Sharpe Morgan Hoyle Allen Rich Rich Grant Proctor Diaz Graham Watkins Hinton Marsh Hewitt Branch Walton O'Brien Case Watts Christensen Parks Hardin Lucas Eason Davidson Whitehead Rose Sparks Moore Pearson Rodgers Graves Scarborough Sutton Sinclair Bowman Olsen Love McLean Christian Lamb James Chandler Stout Cowan Golden Bowling Beasley Clapp Abrams Tilley Morse Boykin Sumner Cassidy Davidson Heath Blanchard McAllister McKenzie Byrne Schroeder Griffin Gross Perkins Robertson Palmer Brady Rowe Zhang Hodge Li Bowling Justice Glass Willis Hester Floyd Graves Fischer Norman Chan Hunt Byrd Lane Kaplan Heller May Jennings Hanna Locklear Holloway Jones Glover Vick O'Donnell Goldman McKenna Starr Stone McClure Watson Monroe Abbott Singer Hall Farrell Lucas Norman Atkins Monroe Robertson Sykes Reid Chandler Finch Hobbs Adkins Kinney Whitaker Alexander Conner Waters Becker Rollins Love Adkins Black Fox Hatcher Wu Lloyd Joyce Welch Matthews Chappell MacDonald Kane Butler Pickett Bowman Barton Kennedy Branch Thornton McNeill Weinstein Middleton Moss Lucas Rich Carlton Brady Schultz Nichols Harvey Stevenson Houston Dunn West O'Brien Barr Snyder Cain Heath Boswell Olsen Pittman Weiner Petersen Davis Coleman Terrell Norman Burch Weiner Parrott Henry Gray Chang McLean Eason Weeks Siegel Puckett Heath Hoyle Garrett Neal Baker Goldman Shaffer Choi Carver".split(' ')
        names[rand(names.size)]
      end

      # Get a placeholder 140 character tweet about Philip the Purple Otter
      # Via http://www.kevadamson.com/talking-of-design/article/140-alternative-characters-to-lorem-ipsum
      # @return [String]
      def tweet
        tweets = ['Far away, in a forest next to a river beneath the mountains, there lived a small purple otter called Philip. Philip likes sausages. The End.',
                  'He liked the quality sausages from Marks & Spencer but due to the recession he had been forced to shop in a less desirable supermarket. End.',
                  'He awoke one day to find his pile of sausages missing. Roger the greedy boar with human eyes, had skateboarded into the forest & eaten them!']
        tweets[rand(tweets.size)]
      end

      # Get a placeholder email address
      # @return [String]
      def email
        delimiters = ['_', '-', '']
        domains = %w(gmail.com yahoo.com hotmail.com email.com live.com me.com mac.com aol.com fastmail.com mail.com)
        username = name.gsub(/[^\w]/, delimiters[rand(delimiters.size)])
        "#{username}@#{domains[rand(domains.size)]}".downcase
      end

      # Get a placeholder image, using placehold.it by default
      # @param [String] size
      # @param [Hash] options
      # @return [String]
      def image(size, options={})
        domain           = options[:domain] || 'http://placehold.it'
        src              = "#{domain}/#{size}"
        hex              = %w(a b c d e f 0 1 2 3 4 5 6 7 8 9)
        background_color = options[:background_color]
        color            = options[:color]

        if options[:random_color]
          background_color = hex.sample(6).join
          color = hex.sample(6).join
        end

        src << "/#{background_color.sub(/^#/, '')}" if background_color
        src << '/ccc' if background_color.nil? && color
        src << "/#{color.sub(/^#/, '')}" if color
        src << "&text=#{Rack::Utils.escape(options[:text])}" if options[:text]

        src
      end

      # Pick a random item from a given range
      # @param [Range] range
      # @return [Object]
      def randm(range)
        a = range.to_a
        a[rand(a.length)]
      end
    end
  end
end
