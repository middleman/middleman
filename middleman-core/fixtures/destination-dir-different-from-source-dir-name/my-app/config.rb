# frozen_string_literal: true

files.watch :source, path: File.join(root, '..', 'external'),
                     destination_dir: 'my_dir'
