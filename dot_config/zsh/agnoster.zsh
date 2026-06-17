if (( ${+functions[_prompt_agnoster_pwd]} &&
      ${+functions[_prompt_agnoster_standout_segment]} &&
      ! ${+functions[_prompt_agnoster_pwd_without_datetime]} )); then
  functions[_prompt_agnoster_pwd_without_datetime]=${functions[_prompt_agnoster_pwd]}

  _prompt_agnoster_datetime() {
    _prompt_agnoster_standout_segment cyan ' %D{%Y-%m-%d %H:%M:%S} '
  }

  _prompt_agnoster_pwd() {
    _prompt_agnoster_datetime
    _prompt_agnoster_pwd_without_datetime "$@"
  }
fi
