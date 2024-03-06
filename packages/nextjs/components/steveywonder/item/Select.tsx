import { Dispatch } from "react";
import { ContractName } from "~~/utils/scaffold-eth/contract";

type Props = {
  option: OptionType;
  setOption: Dispatch<OptionType>;
};

export type OptionType = Exclude<ContractName, "SteveyWonder" | "Account" | "ERC6551Registry">;

export const Select = ({ option, setOption }: Props) => {
  const options: { [key in OptionType]: string } = {
    TShirt: "T-Shirt",
    Pants: "Pants",
    Shoes: "Shoes",
    Hairs: "Hairs",
    Glasses: "Glasses",
  };

  const handleSetOption = (e: React.ChangeEvent<HTMLSelectElement>) => {
    setOption(e.target.value as OptionType);
  };

  return (
    <div className="dropdown">
      <select className="select select-primary select-bordered w-max" value={option} onChange={handleSetOption}>
        {Object.entries(options).map(([value, displayName], index) => (
          <option key={index} value={value}>
            {displayName}
          </option>
        ))}
      </select>
    </div>
  );
};
