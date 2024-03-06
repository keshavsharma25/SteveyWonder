import { ShowTokenURI } from "../common/ShowTokenURI";
import { OptionType } from "./Select";
import { useAccount } from "wagmi";
import { useScaffoldContractRead } from "~~/hooks/scaffold-eth";

type Props = {
  option: OptionType;
  tba: string;
  tokenIndex: bigint;
};

export const Item = ({ option, tba, tokenIndex }: Props) => {
  const { address } = useAccount();

  const { data: tokenId } = useScaffoldContractRead({
    contractName: option,
    functionName: "tokenOfOwnerByIndex",
    args: [tba, tokenIndex],
  });

  const { data: tokenOwner } = useScaffoldContractRead({
    contractName: option,
    functionName: "ownerOf",
    args: [tokenId],
  });

  return (
    <div>
      {address === tokenOwner ? (
        <div>
          {tokenId !== undefined && <ShowTokenURI contractName={option} height={200} width={200} tokenId={tokenId} />}
        </div>
      ) : (
        <div className="cursor-pointer">
          {tokenId !== undefined && <ShowTokenURI contractName={option} height={200} width={200} tokenId={tokenId} />}
        </div>
      )}
    </div>
  );
};
