import toast from "react-hot-toast";
import { useScaffoldContractWrite } from "~~/hooks/scaffold-eth";
import { cn } from "~~/utils/cn";
import { ContractName } from "~~/utils/scaffold-eth/contract";

type Props = {
  name: string;
  contractName: Exclude<ContractName, "SteveyWonder" | "Account" | "ERC6551Registry">;
  tokenId: number;
};

export const MintAccs = ({ name, contractName, tokenId }: Props) => {
  // const { address } = useAccount();

  const { write, isLoading } = useScaffoldContractWrite({
    contractName: contractName,
    functionName: "safeMint",
    args: [BigInt(tokenId)],
    onSuccess: () => {
      toast("Success! You can now see your new accessory in your wallet.", {
        icon: "👏",
        style: {
          background: "#5AB562",
          color: "white",
        },
      });
    },
  });

  return (
    <button
      onClick={() => {
        write?.();
      }}
      className={cn(
        "flex items-center text-xl bg-[#3C44FF] hover:bg-[#3036cc] text-white font-medium py-2 px-4 rounded",
      )}
    >
      {isLoading ? <span className="loading loading-spinner loading-md"></span> : <>{name}</>}
    </button>
  );
};
