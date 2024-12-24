$FilePath = 'C:\Users\Public\Pictures\Background.jpg'

$Code = @'
using System.Runtime.InteropServices;

namespace Win32{
    
    public class Wallpaper{

      [DllImport("user32.dll", CharSet=CharSet.Auto)]
      static  extern int SystemParametersInfo (int uAction , int uParam , string lpvParam , int fuWinIni) ;

      public static void SetWallpaper(string thePath){
         SystemParametersInfo(20,0,thePath,3);
      }
    }
}
'@

Add-Type $Code

[Win32.Wallpaper]::SetWallpaper($FilePath)