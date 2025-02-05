## Represent a local repository of exercises, at a given filesystem directory
class ExerciseRepository

  include WithFileReading

  def initialize(author, language, dir)
    @author = author
    @language = language
    @dir = File.expand_path(dir)
  end

  ## Process files in the repository, logging errors
  ## to a given ImportLog, and yields each processed root
  def process_files(log)
    each_exercise_file do |root, position, original_id, name|

      description = markdown(root, 'description') || (log.no_description name; next)

      hint = markdown(root, 'hint')

      corollary = markdown(root, 'corollary')

      meta = meta(root) || (log.no_meta(name); next)

      test_code = test_code(root) || (log.no_test name; next)

      extra_code = extra_code(root)

      expectations = (expectations(root).try { |it| it['expectations'] } || []).map do |e|
        {binding: e['binding'], inspection: e['inspection']}
      end

      yield original_id,
          {name: name,
           description: description,
           hint: hint,
           corollary: corollary,
           tag_list: meta['tags'],
           locale: meta['locale'],
           layout: meta['layout'] || Exercise.default_layout,
           language: @language,
           expectations: expectations,
           author: @author,
           test: test_code,
           extra_code: extra_code,
           position: position}
    end
  end

  private

  def each_exercise_file
    check_exists
    Dir.glob("#{@dir}/**").sort.each_with_index do |file, index|
      basename = File.basename(file)
      match = /(\d*)_(.+)/.match basename
      next unless match
      yield file, index + 1, match[1].to_i, match[2]
    end
  end

  def check_exists
    raise "directory #{@dir} must exist" unless File.exist? @dir
  end

  def markdown(root, filename)
    read_file "#{root}/#{filename}.md"
  end

  def test_code(root)
    read_code_file(root, 'test')
  end

  def extra_code(root)
    read_code_file(root, 'extra')
  end

  def yaml(root, filename)
    read_yaml_file "#{root}/#{filename}.yml"
  end

  def meta(root)
    yaml(root, 'meta')
  end

  def expectations(root)
    yaml(root, 'expectations')
  end
end
