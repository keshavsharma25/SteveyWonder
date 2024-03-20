import { useEffect } from "react";
import { useDarkMode, useIsMounted } from "usehooks-ts";

export const SwitchTheme = ({ className }: { className?: string }) => {
  const { isDarkMode } = useDarkMode();
  const isMounted = useIsMounted();

  useEffect(() => {
    const body = document.body;
    body.setAttribute("data-theme", isDarkMode ? "scaffoldEthDark" : "scaffoldEth");
  }, [isDarkMode]);

  return (
    <div className={`flex space-x-2 text-sm ${className}`}>
      {isMounted() && (
        <label htmlFor="theme-toggle" className={`swap swap-rotate ${!isDarkMode ? "swap-active" : ""}`}></label>
      )}
    </div>
  );
};
