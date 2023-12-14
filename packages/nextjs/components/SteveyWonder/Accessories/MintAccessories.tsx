import { useScaffoldContractWrite } from "~~/hooks/scaffold-eth";
import { ContractName } from "~~/utils/scaffold-eth/contract";

type Props = {
  name: string;
  contractName: Exclude<ContractName, "SteveyWonder" | "Account" | "ERC6551Registry">;
  tokenId: bigint;
};

export const MintAccessories = ({ name, contractName, tokenId }: Props) => {
  const { write } = useScaffoldContractWrite({
    contractName: contractName,
    functionName: "safeMint",
    args: [tokenId],
  });

  return (
    <button
      onClick={() => {
        write?.();
      }}
      className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
    >
      {name}
    </button>
  );
};
