require 'minitest/autorun'
require_relative '../../lib/mani/tokenizer'

describe Mani::Tokenizer do
  describe '.get_tokens' do
    describe 'when there are no tags' do
      it 'returns the correct tokens' do
        source = 'static'
        actual = Mani::Tokenizer.get_tokens source
        expected = [[:static, 'static']]
        actual.must_equal expected
      end
    end

    describe 'when there is an opening tag and no closing tag' do
      it 'returns the correct tokens' do
        source = 'static {{ static'
        actual = Mani::Tokenizer.get_tokens source
        expected = [
          [:static, 'static {{ static'],
        ]
        actual.must_equal expected
      end
    end

    describe 'when there is a closing tag and no opening tag' do
      it 'returns the correct tokens' do
        source = 'static }} static'
        actual = Mani::Tokenizer.get_tokens source
        expected = [
          [:static, 'static }} static']
        ]
        actual.must_equal expected
      end
    end

    describe 'when there is a commented opening tag and no closing tag' do
      it 'returns the correct tokens' do
        source = 'static %{{ static'
        actual = Mani::Tokenizer.get_tokens source
        expected = [
          [:static, 'static {{ static']
        ]
        actual.must_equal expected
      end
    end

    describe 'when there is a commented closing tag and no opening tag' do
      it 'returns the correct tokens' do
        source = 'static %}} static'
        actual = Mani::Tokenizer.get_tokens source
        expected = [
          [:static, 'static }} static']
        ]
        actual.must_equal expected
      end
    end

    describe 'when there are commented opening and closing tags' do
      it 'returns the correct tokens' do
        source = 'static %{{seq%}} static'
        actual = Mani::Tokenizer.get_tokens source
        expected = [
          [:static, 'static {{seq}} static'],
        ]
        actual.must_equal expected
      end
    end

    describe 'when there is a commented opening tag and a closing tag' do
      it 'returns the correct tokens' do
        source = 'static %{{seq}} static'
        actual = Mani::Tokenizer.get_tokens source
        expected = [
          [:static, 'static {{seq}} static'],
        ]
        actual.must_equal expected
      end
    end

    describe 'when there is an opening tag and a commented closing tag' do
      it 'returns the correct tokens' do
        source = 'static {{seq%}} static'
        actual = Mani::Tokenizer.get_tokens source
        expected = [
          [:static, 'static {{seq}} static'],
        ]
        actual.must_equal expected
      end
    end

    describe 'when there is an empty sequence' do
      it 'returns the correct tokens' do
        source = '{{}}'
        actual = Mani::Tokenizer.get_tokens source
        expected = []
        actual.must_equal expected
      end
    end

    describe 'when there is one, unnested sequence' do
      it 'returns the correct tokens' do
        source = 'static {{seq}} static'
        actual = Mani::Tokenizer.get_tokens source
        expected = [
          [:static, 'static '],
          [:sequence, 'seq'],
          [:static, ' static']
        ]
        actual.must_equal expected
      end
    end

    describe 'when there is a sequence with a commented opening tag within' do
      it 'returns the correct tokens' do
        source = 'static {{seq %{{ }} static'
        actual = Mani::Tokenizer.get_tokens source
        expected = [
          [:static, 'static '],
          [:sequence, 'seq {{ '],
          [:static, ' static']
        ]
        actual.must_equal expected
      end
    end

    describe 'when there is a sequence with a commented closing tag within' do
      it 'returns the correct tokens' do
        source = 'static {{seq %}} }} static'
        actual = Mani::Tokenizer.get_tokens source
        expected = [
          [:static, 'static '],
          [:sequence, 'seq }} '],
          [:static, ' static']
        ]
        actual.must_equal expected
      end
    end

    describe 'when there are commented tags within a sequence' do
      it 'returns the correct tokens' do
        source = 'static {{seq %{{ nested %}} }} static'
        actual = Mani::Tokenizer.get_tokens source
        expected = [
          [:static, 'static '],
          [:sequence, 'seq {{ nested }} '],
          [:static, ' static']
        ]
        actual.must_equal expected
      end
    end

    describe 'when there is a sequence within commented tags' do
      it 'returns the correct tokens' do
        source = 'static %{{comment {{seq}} %}} static'
        actual = Mani::Tokenizer.get_tokens source
        expected = [
          [:static, 'static {{comment '],
          [:sequence, 'seq'],
          [:static, ' }} static']
        ]
        actual.must_equal expected
      end
    end

    describe 'when there is a sequence within a sequence' do
      it 'returns the correct tokens' do
        source = 'static {{nested {{seq}} }} static'
        actual = Mani::Tokenizer.get_tokens source
        expected = [
          [:static, 'static '],
          [:sequence, 'nested {{seq'],
          [:static, ' }} static']
        ]
        actual.must_equal expected
      end
    end

    describe 'when there are multiple, unnested sequence' do
      it 'returns the correct tokens' do
        source = '{{seq}} static {{second seq}} more static'
        actual = Mani::Tokenizer.get_tokens source
        expected = [
          [:sequence, 'seq'],
          [:static, ' static '],
          [:sequence, 'second seq'],
          [:static, ' more static']
        ]
        actual.must_equal expected
      end
    end

    describe 'when there are multiple empty sequence' do
      it 'returns the correct tokens' do
        source = '{{}} static {{}}'
        actual = Mani::Tokenizer.get_tokens source
        expected = [
          [:static, ' static '],
        ]
        actual.must_equal expected
      end
    end

    describe 'when the tags are out of order' do
      it 'returns the correct tokens' do
        source = '}} static {{'
        actual = Mani::Tokenizer.get_tokens source
        expected = [
          [:static, '}} static {{'],
        ]
        actual.must_equal expected
      end
    end

    describe 'when the commenting tags are out of order' do
      it 'returns the correct tokens' do
        source = '%}} static %{{'
        actual = Mani::Tokenizer.get_tokens source
        expected = [
          [:static, '}} static {{'],
        ]
        actual.must_equal expected
      end
    end

    describe 'when literal commenting tags are used' do
      it 'returns the correct tokens' do
        source = '%%{{ static %%}} more static'
        actual = Mani::Tokenizer.get_tokens source
        expected = [
          [:static, '%{{ static %}} more static'],
        ]
        actual.must_equal expected
      end
    end
  end
end
