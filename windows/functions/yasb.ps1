function yasb {
  $script:__yasb_repo = [System.IO.Path]::Combine("$HOME",'yasb')
  $script:__yasb_path = "$__yasb_repo\src\main.py"

  Write-Host "$script:__yasb_path"

  Push-Location $script:__yasb_repo

  try {
    # pip install -U -r requirements.txt

    # https://github.com/da-rth/yasb/issues/120#issuecomment-1877738689
    # pip install pyqt6-qt6==6.3.1

    # todo? constrain?
    python $script:__yasb_path
  } catch {

  } finally {
    Pop-Location
  }
}