import toast from "react-hot-toast";
import { useScaffoldContractWrite } from "~~/hooks/scaffold-eth";
import { cn } from "~~/utils/cn";

type Props = {
  name: string;
  className?: string;
};

export const MintStevey = ({ name, className }: Props) => {
  const { writeAsync, isSuccess } = useScaffoldContractWrite({
    contractName: "SteveyWonder",
    functionName: "safeMint",
  });

  const handleMintButton = async () => {
    try {
      await writeAsync();
      if (isSuccess) {
        toast.success(`Minted SteveyWonder`);
      }
    } catch (err: unknown) {
      console.error(err);
      toast.error(`Error: ${err}`);
    }
  };

  return (
    <button
      onClick={handleMintButton}
      className={cn("px-4 py-4 rounded-lg cursor-pointer bg-[#3C44FF] font-medium", className)}
    >
      {name}
    </button>
  );
};
