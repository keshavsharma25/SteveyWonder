import { useScaffoldContractWrite } from "~~/hooks/scaffold-eth";
import { cn } from "~~/utils/cn";

type Props = {
  name: string;
  className?: string;
};

export const MintStevey = ({ name, className }: Props) => {
  const { write } = useScaffoldContractWrite({
    contractName: "SteveyWonder",
    functionName: "safeMint",
  });

  return (
    <button
      onClick={() => {
        write?.();
      }}
      className={cn("bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded", className)}
    >
      {name}
    </button>
  );
};
