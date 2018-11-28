function [Flat_Test_patterns, TwoD_Test_patterns] = create_test_pattern_set(str)
    str_len = length(str);
    for i = 1:str_len
      str_letter = str(i);
      [Flat_Test_pattern, TwoD_Test_pattern] = create_pattern(str_letter);
      Flat_Test_patterns(:, i) = Flat_Test_pattern;
      TwoD_Test_patterns(:, :, i) = TwoD_Test_pattern;
    end;
    return;